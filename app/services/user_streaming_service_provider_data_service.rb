# frozen_string_literal: true

module UserStreamingServiceProviderDataService
  MOVIE_FILTER_TIMEOUT = 5 # seconds, per TMDB request
  MOVIE_FILTER_DEADLINE = 10 # seconds, for all of a page's TMDB requests
  # Shared by all requests, so at most this many TMDB requests run at once
  MOVIE_FILTER_POOL = Concurrent::FixedThreadPool.new(10)

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

      movie_ids_and_tmdb_ids = movies.pluck(:id, :tmdb_id)
      futures = movie_ids_and_tmdb_ids.map do |_movie_id, tmdb_id|
        Concurrent::Promises.future_on(MOVIE_FILTER_POOL) do
          Rails.application.executor.wrap do
            results = fetch_us_providers(tmdb_id: tmdb_id, media_type: 'movie', timeout: MOVIE_FILTER_TIMEOUT)
            free_provider_ids(results).intersect?(user_provider_ids)
          end
        end
      end

      # Like Promise.allSettled, with a deadline for the whole batch
      ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
        Concurrent::Promises.zip_futures(*futures).wait(MOVIE_FILTER_DEADLINE)
      end

      movie_ids_and_tmdb_ids.zip(futures).each do |(movie_id, _tmdb_id), future|
        if future.fulfilled?
          availability.available_ids << movie_id if future.value
        else
          # Rejected (raised an error) or still pending when the deadline hit
          failure = future.rejected? ? "#{future.reason.class}: #{future.reason.message}" : 'timed out'
          Rails.logger.warn("Streaming availability check failed for movie #{movie_id}: #{failure}")
          availability.failed_ids << movie_id
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
