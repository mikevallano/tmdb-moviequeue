# frozen_string_literal: true

module TvSeriesDataService
  class << self
    def get_tv_series_names(query)
      data = Tmdb::Client.request(:tv_series_search, query: query)[:results]
      data.map { |d| d[:name] }.uniq
    end

    def get_tv_series_search_results(query)
      data = Tmdb::Client.request(:tv_series_search, query: query)[:results]
      TVSeries.parse_search_records(data) if data.present?
    end

    def get_tv_series_data(series_id)
      data = Tmdb::Client.request(:tv_series_data, series_id: series_id)
      TVSeries.parse_record(data, series_id)
    end

    def get_tv_season_data(series:, season_number:)
      params = { series_id: series.show_id, season_number: season_number }
      data = Tmdb::Client.request(:tv_season_data, params)
      TVSeason.parse_record(
        series: series,
        season_data: data
      )
    end

    def get_tv_episode_data(series_id:, season_number:, episode_number:)
      params = { series_id: series_id, season_number: season_number, episode_number: episode_number }
      data = Tmdb::Client.request(:tv_episode_data, params)
      TVEpisode.parse_record(data)
    end

    def get_actor_tv_appearance_credits(credit_id)
      data = Tmdb::Client.request(:credits_data, credit_id: credit_id)
      TVActorCredit.parse_record(data)
    end
  end
end
