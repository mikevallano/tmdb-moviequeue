FactoryBot.define do
  factory :tv_series, class: 'TVSeries' do
    show_id { rand(100) }
    first_air_date { rand(4..6).years.ago.to_date }
    last_air_date { rand(1..3).years.ago.to_date }
    sequence(:show_name) { |n| "show name#{n}" }
    backdrop_path { "/#{rand(10000)}.jpg" }
    poster_path { "/#{rand(10000)}.jpg" }
    number_of_episodes { 5 }
    number_of_seasons { 5 }
    overview { 'lorem ipusm' }
    seasons { [1, 2, 3, 4, 5] }
    actors { [] }

    initialize_with do
      new(
        show_id: show_id,
        first_air_date: first_air_date,
        last_air_date: last_air_date,
        show_name: show_name,
        backdrop_path: backdrop_path,
        poster_path: poster_path,
        number_of_episodes: number_of_episodes,
        number_of_seasons: number_of_seasons,
        overview: overview,
        seasons: seasons,
        actors: actors
      )
    end
  end
end
