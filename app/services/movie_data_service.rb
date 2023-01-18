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

  class << self
    def update_movie(movie)
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

    def get_movie_title_search_results(movie_title)
      data = Tmdb::Client.request(:movie_search, query: movie_title)[:results]
      not_found = "No results for '#{movie_title}'." if data.blank?
      movies = MovieSearchResult.build_list(data) if data.present?

      OpenStruct.new(
        movie_title: movie_title,
        not_found_message: not_found,
        query: movie_title,
        movies: movies
      )
    end

    def get_advanced_movie_search_results(params)
      searched_terms = SearchParamParser.parse_movie_params_for_display(params)
      data = if params[:actor_name].present?
       person_id = Tmdb::Client.request(:person_search, query: params[:actor_name])&.dig(:results)&.first&.dig(:id)
       return OpenStruct.new(not_found_message: "No results for actor '#{params[:actor_name]}'.") if person_id.blank?

        Tmdb::Client.request(:discover_search, params.except(:actor_name).merge(people: person_id))
      else
        Tmdb::Client.request(:discover_search, params.except(:actor_name))
      end

      movie_results = data.dig(:results)
      return OpenStruct.new(not_found_message: "No results for #{searched_terms}.") if movie_results.blank?

      movies = MovieSearchResult.build_list(movie_results)
      total_pages = data.fetch(:total_pages)
      current_page = data[:page]

      OpenStruct.new(
        searched_terms: searched_terms,
        searched_params: {
          actor_name: params[:actor_name],
          company: params[:company],
          date: params[:date],
          genre: params[:genre],
          mpaa_rating: params[:mpaa_rating],
          sort_by: params[:sort_by],
          timeframe: params[:timeframe],
          year: params[:year]
        },
        page: current_page,
        movies: movies,
        not_found_message: nil,
        current_page: current_page,
        previous_page: (current_page - 1 if current_page > 1),
        next_page: (current_page + 1 unless current_page >= total_pages),
        total_pages: total_pages
      )
    end

    def get_movies_for_actor(actor_name:, page:, sort_by:)
      person_data = Tmdb::Client.request(:person_search, query: actor_name)[:results]&.first

      if person_data.blank?
        return OpenStruct.new(
          not_found_message: "No actors found for '#{actor_name}'."
        )
      end

      movie_params = {
        people: person_data[:id],
        page: page,
        sort_by: sort_by
      }
      movie_data = Tmdb::Client.request(:discover_search, movie_params)
      movie_results = movie_data[:results]
      total_pages = movie_data&.fetch(:total_pages).zero? ? 1 : movie_data&.fetch(:total_pages)
      not_found_message = "No movies found for '#{actor_name}'." if movie_results.blank?
      current_page = movie_data[:page]

      OpenStruct.new(
        id: person_data[:id],
        actor: person_data,
        actor_name: person_data[:name],
        movies: MovieSearchResult.build_list(movie_results),
        not_found_message: not_found_message,
        current_page: current_page,
        previous_page: (current_page - 1 if current_page > 1),
        next_page: (current_page + 1 unless current_page >= total_pages),
        total_pages: total_pages
      )
    end

    def get_movie_data(tmdb_movie_id)
      data = Tmdb::Client.request(:movie_data, movie_id: tmdb_movie_id)
      MovieMore.initialize_from_parsed_data(data)
    end

    def get_movie_cast(tmdb_movie_id)
      data = Tmdb::Client.request(:movie_data, movie_id: tmdb_movie_id)

      director_credits = data.dig(:credits, :crew)&.select { |crew| crew[:job] == 'Director' }
      editor_credits = data.dig(:credits, :crew)&.select { |crew| crew[:job] == 'Editor' }

      OpenStruct.new(
        movie: get_movie_data(tmdb_movie_id),
        actors: MovieCast.parse_results(data.dig(:credits, :cast)),
        directors: MovieDirecting.parse_results(director_credits),
        editors: MovieEditing.parse_results(editor_credits)
      )
    end

    def get_movie_titles(query)
      data = Tmdb::Client.request(:movie_search, query: query)[:results]
      data.map { |d| d[:title] }.uniq
    end

    def get_common_actors_between_movies(movie_one_title, movie_two_title)
      movie_one_results = get_movie_title_search_results(movie_one_title)
      movie_two_results = get_movie_title_search_results(movie_two_title)
      not_found_message = movie_one_results.not_found_message.presence || movie_two_results.not_found_message.presence

      if not_found_message.present?
        OpenStruct.new(not_found_message: not_found_message)
      else
        movie_one = get_movie_data(movie_one_results.movies.first.tmdb_id)
        movie_two = get_movie_data(movie_two_results.movies.first.tmdb_id)
        OpenStruct.new(
          movie_one: movie_one,
          movie_two: movie_two,
          common_actors: movie_one.actors & movie_two.actors,
          not_found_message: nil
        )
      end
    end

    def get_common_movies_between_multiple_actors(actor_names: nil, paginate_actor_names: nil, page: nil, sort_by: nil)
      names = actor_names.uniq.reject { |name| name == '' }.compact.presence || paginate_actor_names.presence.split(';')
      return if names.blank?

      not_found_messages = []
      person_ids = []
      actor_names = []

      names.compact.each do |name|
        data = Tmdb::Client.request(:person_search, query: name)[:results]&.first
        if data.blank?
          not_found_messages << "No actor found for '#{name}'."
        else
          person_ids << data[:id]
          actor_names << data[:name]
        end
      end

      if not_found_messages.present?
        return OpenStruct.new(
          not_found_message: not_found_messages.compact.join(' ')
        )
      end

      movie_response = Tmdb::Client.request(:discover_search,
                               people: person_ids.join(','),
                               page: page,
                               sort_by: sort_by)

      if movie_response[:results].blank?
        return OpenStruct.new(
          not_found_message: "No results for movies with #{actor_names.to_sentence}."
        )
      end

      current_page = movie_response[:page]
      OpenStruct.new(
        actor_names: actor_names,
        paginate_actor_names: actor_names.join(';'),
        common_movies: MovieSearchResult.build_list(movie_response[:results]),
        not_found_message: nil,
        current_page: current_page,
        previous_page: (current_page - 1 if current_page > 1),
        next_page: (current_page + 1 unless current_page >= movie_response[:total_pages]),
        total_pages: movie_response[:total_pages]
      )
    end
  end
end
