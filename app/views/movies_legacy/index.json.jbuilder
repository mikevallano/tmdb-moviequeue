json.array!(@movies) do |movie|
  json.extract! movie, :id, :tmdb_id, :imdb_id, :backdrop_path, :poster_path, :release_date, :overview, :trailer, :vote_average, :popularity
  json.url movie_url(movie, format: :json)
end
