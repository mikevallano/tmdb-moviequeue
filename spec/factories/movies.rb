FactoryBot.define do
  factory :movie do
    title { FFaker::Movie.title }
    sequence(:tmdb_id) { |n| n + 10 }
    imdb_id { FFaker::Product.model }
    backdrop_path { '/lGAaaOzqw8nc14HOgSP58TWWo1y.jpg' }
    poster_path { '/aZeX4XNSqa08TdMHRB1gDLO6GOi.jpg' }
    release_date { '2015-12-07' }
    overview { FFaker::HipsterIpsum.paragraph }
    trailer { 'h2tY82z3xXU' }
    vote_average { 7.5 }
    popularity { 1.5 }
    mpaa_rating { 'R' }
    director { FFaker::Name.name }

    factory :invalid_movie do
      tmdb_id { nil }
    end

    factory :movie_in_tmdb do
      title { 'Fargo' }
      tmdb_id { 275 }
      imdb_id { 'tt0116282' }
      backdrop_path { '/747dgDfL5d8esobk7h4odaOFhUq.jpg' }
      poster_path { '/kKpORM0G7xDvJGQiXpQ0wUp9Dwo.jpg' }
      release_date { 'Fri, 08 Mar 1996' }
      overview { 'Jerry, a small-town Minnesota car salesman' }
      trailer { 'h2tY82z3xXU' }
      vote_average { 7.9 }
      popularity { 17.27 }
      mpaa_rating { 'R' }
      director { 'Joel Coen' }
    end
  end
end
