# frozen_string_literal: true

class GuaranteedMovie
  class << self
    def find(tmdb_id)
      Movie.find_by(tmdb_id: tmdb_id) || create_from_api_data(tmdb_id)
    end

    private

    def create_from_api_data(tmdb_id)
      movie = Tmdb::Client.movie(tmdb_id)
      Movie.create(
        title: movie.title,
        tmdb_id: movie.tmdb_id,
        imdb_id: movie.imdb_id,
        genres: movie.genres,
        actors: movie.actors,
        adult: movie.adult,
        backdrop_path: movie.backdrop_path,
        poster_path: movie.poster_path,
        release_date: movie.release_date,
        overview: movie.overview,
        trailer: movie.trailer,
        director: movie.director,
        director_id: movie.director_id,
        vote_average: movie.vote_average,
        popularity: movie.popularity,
        runtime: movie.runtime,
        mpaa_rating: movie.mpaa_rating
      )
    end
  end
end
