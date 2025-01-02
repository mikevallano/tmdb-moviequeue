# frozen_string_literal: true

module StreamingServiceProviderDataService
  class << self
    def get_providers(tmdb_id:, title:, media_type:, media_format:, release_date: nil)
      params = { tmdb_id: tmdb_id, media_type: media_type }
      results = Tmdb::Client.request(:streaming_service_providers, params)&.dig(:results, :US)
binding.pry
      parameterized_title = title.parameterize(separator: '+')
      default_providers = [
        # Find more providers at TMDB's watch_provider partner: https://www.justwatch.com/us
        {
          display_name: 'Hoopla',
          tmdb_provider_name: 'Hoopla',
          tmdb_provider_id: 212,
          pay_model: 'try',
          url: "https://www.hoopladigital.com/search?q=#{parameterized_title}&scope=everything&type=direct&kindId=7"
        },
        {
          display_name: 'Kanopy',
          tmdb_provider_name: 'Kanopy',
          tmdb_provider_id: 191,
          pay_model: 'try',
          url: "https://www.kanopy.com"
        },
        {
          display_name: 'Netflix',
          tmdb_provider_name: 'Netflix',
          tmdb_provider_id: 8,
          pay_model: 'try',
          url: "http://www.netflix.com/search/?q=#{title}"
        },
        {
          display_name: 'Amazon',
          tmdb_provider_name: 'Amazon Prime Video',
          tmdb_provider_id: 9,
          pay_model: 'try',
          url: "https://www.amazon.com/s?k=#{parameterized_title}&i=instant-video"
        },
        {
          display_name: 'Amazon',
          tmdb_provider_name: 'Amazon Video',
          tmdb_provider_id: 10,
          pay_model: 'try',
          url: "https://www.amazon.com/s?k=#{parameterized_title}&i=instant-video"
        },
        {
          display_name: 'YouTube',
          tmdb_provider_name: 'YouTube',
          tmdb_provider_id: 192,
          pay_model: 'try',
          url: "https://www.youtube.com/results?search_query=#{parameterized_title}+full+#{media_format} #{release_date&.stamp('2001')}"
        },
        {
          display_name: 'Fandango',
          tmdb_provider_name: 'Fandango At Home',
          tmdb_provider_id: 7,
          pay_model: 'try',
          url: "https://athome.fandango.com/content/movies/search?searchString=#{title}"
        },
        # {
        #   display_name: 'VUDU',
        #   tmdb_provider_name: 'VUDU Free',
        #   tmdb_provider_id: 332,
        #   pay_model: 'try',
        #   url: "https://athome.fandango.com/content/movies/search?searchString=#{title}"
        # },
        {
          display_name: 'Peacock',
          tmdb_provider_name: 'Peacock Premium',
          tmdb_provider_id: 386,
          pay_model: 'try',
          url: "https://www.peacocktv.com/"
        },
        {
          display_name: 'Peacock+',
          tmdb_provider_name: 'Peacock Premium Plus',
          tmdb_provider_id: 387,
          pay_model: 'try',
          url: "https://www.peacocktv.com/"
        },
      ]
      return default_providers if results.nil?

      result_free_provider_ids = results[:free]&.map { |result| result[:provider_id] } || []
      result_flatrate_provider_ids = results[:flatrate]&.map { |result| result[:provider_id] } || []
      result_rent_provider_ids = results[:rent]&.map { |result| result[:provider_id] } || []
      result_buy_provider_ids = results[:buy]&.map { |result| result[:provider_id] } || []

      default_providers.map do |provider|
        pay_model = if result_flatrate_provider_ids.include?(provider[:tmdb_provider_id]) || result_free_provider_ids.include?(provider[:tmdb_provider_id])
          'free'
        elsif result_rent_provider_ids.include?(provider[:tmdb_provider_id])
          'rent'
        elsif result_buy_provider_ids.include?(provider[:tmdb_provider_id])
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
