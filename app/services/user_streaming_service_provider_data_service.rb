# frozen_string_literal: true

module UserStreamingServiceProviderDataService
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

      params = { tmdb_id: tmdb_id, media_type: media_type }
      results = Tmdb::Client.request(:streaming_service_providers, params)&.dig(:results, :US)
      return available_providers if results.nil?

      result_free_provider_ids = results[:free]&.map { |result| result[:provider_id] } || []
      result_flatrate_provider_ids = results[:flatrate]&.map { |result| result[:provider_id] } || []
      result_rent_provider_ids = results[:rent]&.map { |result| result[:provider_id] } || []
      result_buy_provider_ids = results[:buy]&.map { |result| result[:provider_id] } || []      

      user.streaming_service_providers.map do |provider|
        if result_flatrate_provider_ids.include?(provider[:tmdb_provider_id]) || result_free_provider_ids.include?(provider[:tmdb_provider_id])
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
  end
end
