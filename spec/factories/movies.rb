FactoryGirl.define do
  factory :movie do
    title { FFaker::Movie.title }
    tmdb_id { rand(1..9999) }
    imdb_id { FFaker::Product.model }
    backdrop_path "/lGAaaOzqw8nc14HOgSP58TWWo1y.jpg"
    poster_path "/aZeX4XNSqa08TdMHRB1gDLO6GOi.jpg"
    release_date "2015-12-07"
    overview { FFaker::HipsterIpsum.paragraph }
    trailer "h2tY82z3xXU"
    vote_average 7.5
    popularity 1.5

    factory :invalid_movie do
      tmdb_id nil
    end
  end

end
