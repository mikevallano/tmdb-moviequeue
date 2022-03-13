# frozen_string_literal: true

module MovieDataService
  LIST_SORT_OPTIONS = [ ["title", "title"], ["shortest runtime", "shortest runtime"],
  ["longest runtime", "longest runtime"], ["newest release", "newest release"],
  ["vote average", "vote average"], ["recently added to list", "recently added to list"],
  ["watched movies", "watched movies"], ["unwatched movies", "unwatched movies"],
  ["recently watched", "recently watched"], ["highest priority", "highest priority"],
  ["only show unwatched", "only show unwatched"], ["only show watched", "only show watched"] ]

  MY_MOVIES_SORT_OPTIONS = [ ["title", "title"], ["shortest runtime", "shortest runtime"],
  ["longest runtime", "longest runtime"], ["newest release", "newest release"],
  ["vote average", "vote average"], ["watched movies", "watched movies"], ["recently watched", "recently watched"],
  ["unwatched movies", "unwatched movies"], ["only show unwatched", "only show unwatched"],
  ["only show watched", "only show watched"], ["movies not on a list", "movies not on a list"] ]

  GENRES = [["Action", 28], ["Adventure", 12], ["Animation", 16], ["Comedy", 35], ["Crime", 80],
  ["Documentary", 99], ["Drama", 18], ["Family", 10751], ["Fantasy", 14], ["Foreign", 10769], ["History", 36],
  ["Horror", 27], ["Music", 10402], ["Mystery", 9648], ["Romance", 10749], ["Science Fiction", 878], ["TV Movie", 10770],
  ["Thriller", 53], ["War", 10752], ["Western", 37]]

  MPAA_RATINGS = [ ["R", "R"], ["NC-17", "NC-17"], ["PG-13", "PG-13"], ["G", "G"] ]

  SORT_BY = [ ["Popularity", "popularity"], ["Release date", "release_date"], ["Revenue", "revenue"],
  ["Vote average", "vote_average"], ["Vote count","vote_count"] ]

  YEAR_SELECT = [ ["Exact Year", "exact"], ["After This Year", "after"], ["Before This Year", "before"] ]

  def self.update_movie(movie)
    # I'm not sure why this method uses HTTParty instead
    tmdb_id = movie.tmdb_id.to_s
    movie_url = "#{Tmdb::Client::BASE_URL}/movie/#{tmdb_id}?api_key=#{Tmdb::Client::API_KEY}&append_to_response=trailers,credits,releases"
    api_result = begin
                   HTTParty.get(movie_url).deep_symbolize_keys
                 rescue StandardError
                   nil
                 end
    raise Error, "API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}" unless api_result

    if api_result[:status_code] == 34 && api_result[:status_message]&.include?('could not be found')
      puts "Movie not found, so not updated. Title: #{movie.title}. tmdb_id: #{tmdb_id}"
      return
    elsif api_result[:id]&.to_s != tmdb_id
      raise Error, "API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}"
    end

    updated_data = MovieMore.initialize_from_parsed_data(api_result)

    if movie.title != updated_data.title
      puts "Movie title doesn't match. tmdb_id: #{tmdb_id}. Current title: #{movie.title}. Title in TMDB: #{updated_data.title}"
    end

    movie.update!(
      title: updated_data.title,
      imdb_id: updated_data.imdb_id,
      genres: updated_data.genres,
      actors: updated_data.actors,
      backdrop_path: updated_data.backdrop_path,
      poster_path: updated_data.poster_path,
      release_date: updated_data.release_date,
      overview: updated_data.overview,
      trailer: movie.trailer || updated_data.trailer,
      director: updated_data.director,
      director_id: updated_data.director_id,
      vote_average: updated_data.vote_average,
      popularity: updated_data.popularity,
      runtime: updated_data.runtime,
      mpaa_rating: updated_data.mpaa_rating,
      updated_at: Time.current
    )
  rescue ActiveRecord::RecordInvalid => e
    raise Error, "#{movie.title} failed update. #{e.message}"
  end
end
