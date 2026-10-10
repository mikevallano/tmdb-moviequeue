# frozen_string_literal: true

module UserStreamingServiceProviderDataService
  MOVIE_FILTER_TIMEOUT = 5 # seconds

  class << self
    def check_availability_for_title(user:, tmdb_id:, title:, media_type:, media_format:, release_date: nil)
      available_providers = OpenStruct.new(
        free: [],
        rent: [],
        buy: [],
        not_found: [],
      )

      if user.streaming_service_providers.empty?
        available_providers[:no_providers_selected] = "Please select streaming service providers in your user settings"
        return available_providers 
      end

      results = fetch_us_providers(tmdb_id: tmdb_id, media_type: media_type)
      return available_providers if results.blank?

      result_free_provider_ids = free_provider_ids(results)
      result_rent_provider_ids = results[:rent]&.map { |result| result[:provider_id] } || []
      result_buy_provider_ids = results[:buy]&.map { |result| result[:provider_id] } || []

      user.streaming_service_providers.each do |provider|
        if result_free_provider_ids.include?(provider[:tmdb_provider_id])
          available_providers[:free] << provider
        elsif result_rent_provider_ids.include?(provider[:tmdb_provider_id])
          available_providers[:rent] << provider
        elsif result_buy_provider_ids.include?(provider[:tmdb_provider_id])
          available_providers[:buy] << provider
        else
          available_providers[:not_found] << provider
        end
      end

      available_providers
    end

    # Checks which movies are free or on a subscription (flatrate) for one of the user's providers.
    # Makes one TMDB request per movie (in parallel), so only use with a small number of movies.
    # Returns available_ids, plus failed_ids for movies whose availability couldn't be checked.
    def check_availability_for_movies(user:, movies:)
      availability = OpenStruct.new(available_ids: [], failed_ids: [])
      user_provider_ids = user.streaming_service_providers.map(&:tmdb_provider_id)
      return availability if user_provider_ids.empty?

      threads = movies.pluck(:id, :tmdb_id).map do |movie_id, tmdb_id|
        Thread.new do
          Rails.application.executor.wrap do
            results = fetch_us_providers(tmdb_id: tmdb_id, media_type: 'movie', timeout: MOVIE_FILTER_TIMEOUT)
            [movie_id, free_provider_ids(results).intersect?(user_provider_ids)]
          rescue StandardError => e
            Rails.logger.warn("Streaming availability check failed for movie #{movie_id}: #{e.class}: #{e.message}")
            [movie_id, nil]
          end
        end
      end

      ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
        threads.map(&:value).each do |movie_id, available|
          if available.nil?
            availability.failed_ids << movie_id
          elsif available
            availability.available_ids << movie_id
          end
        end
      end

      availability
    end

    private

    def free_provider_ids(results)
      [*results[:free], *results[:flatrate]].map { |result| result[:provider_id] }
    end

    def fetch_us_providers(tmdb_id:, media_type:, timeout: nil)
      # Caches {} when there's no US data so those titles aren't re-requested
      Rails.cache.fetch("tmdb/watch_providers/#{media_type}/#{tmdb_id}", expires_in: 1.hour) do
        Tmdb::Client.request(:streaming_service_providers, { tmdb_id: tmdb_id, media_type: media_type }, timeout)
          &.dig(:results, :US) || {}
      end
    end
  end
end
