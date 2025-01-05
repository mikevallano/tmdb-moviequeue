# frozen_string_literal: true

module StreamingServiceProviderDataService
  class << self
    def get_providers(tmdb_id:, title:, media_type:, media_format:, release_date: nil)
      params = { tmdb_id: tmdb_id, media_type: media_type }
      results = Tmdb::Client.request(:streaming_service_providers, params)&.dig(:results, :US)

      return StreamingServiceProvider.all if results.nil?
      
      result_free_provider_ids = results[:free]&.map { |result| result[:provider_id] } || []
      result_flatrate_provider_ids = results[:flatrate]&.map { |result| result[:provider_id] } || []
      result_rent_provider_ids = results[:rent]&.map { |result| result[:provider_id] } || []
      result_buy_provider_ids = results[:buy]&.map { |result| result[:provider_id] } || []

      # This method clobbers the class and allows for querying on the pay_model attribute
      StreamingServiceProvider.all.map do |provider|
        pay_model = if result_flatrate_provider_ids.include?(provider[:tmdb_provider_id]) || result_free_provider_ids.include?(provider[:tmdb_provider_id])
          'free'
        elsif result_rent_provider_ids.include?(provider[:tmdb_provider_id])
          'rent'
        elsif result_buy_provider_ids.include?(provider[:tmdb_provider_id])
          'buy'
        else
          'not_found'
        end

        provider.pay_model = pay_model
        provider
      end
    end
  end
end
