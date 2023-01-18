# frozen_string_literal: true

module StreamingServiceProviderDataService
  class << self
    def get_providers(tmdb_id:, title:, media_type:, media_format:, release_date: nil)
      params = { tmdb_id: tmdb_id, media_type: media_type }
      results = Tmdb::Client.request(:streaming_service_providers, params)&.dig(:results, :US)

      parameterized_title = title.parameterize(separator: '+')
      default_providers = [
        # Find more providers at TMDB's watch_provider partner: https://www.justwatch.com/us
        {
          name: 'Hoopla',
          pay_model: 'try',
          url: "https://www.hoopladigital.com/search?q=#{parameterized_title}&scope=everything&type=direct&kindId=7"
        },
        {
          name: 'Netflix',
          pay_model: 'try',
          url: "http://www.netflix.com/search/?q=#{title}"
        },
        {
          name: 'Amazon Prime Video',
          pay_model: 'try',
          url: "https://smile.amazon.com/s?k=#{parameterized_title}&i=instant-video"
        },
        {
          name: 'Amazon Video',
          pay_model: 'try',
          url: "https://smile.amazon.com/s?k=#{parameterized_title}&i=instant-video"
        },
        {
          name: 'YouTube',
          pay_model: 'try',
          url: "https://www.youtube.com/results?search_query=#{parameterized_title}+full+#{media_format} #{release_date&.stamp('2001')}"
        },
        {
          name: 'Vudu',
          pay_model: 'try',
          url: "https://www.vudu.com/content/movies/search?searchString=#{title}"
        },
      ]
      return default_providers if results.nil?

      free_provider_names = results[:free]&.map { |result| result[:provider_name] } || []
      flatrate_provider_names = results[:flatrate]&.map { |result| result[:provider_name] } || []
      rent_provider_names = results[:rent]&.map { |result| result[:provider_name] } || []
      buy_provider_names = results[:buy]&.map { |result| result[:provider_name] } || []

      default_providers.map do |provider|
        pay_model = if flatrate_provider_names.include?(provider[:name]) || free_provider_names.include?(provider[:name])
          'free'
        elsif rent_provider_names.include?(provider[:name])
          'rent'
        elsif buy_provider_names.include?(provider[:name])
          'buy'
        else
          'try'
        end

        provider[:pay_model] = pay_model
        provider
      end
    end
  end
end