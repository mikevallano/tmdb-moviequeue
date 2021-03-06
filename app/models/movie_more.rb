class MovieMore
  def initialize(title, in_db, tmdb_id, release_date, vote_average, genres, overview, actors,
    backdrop_path, poster_path, trailer, imdb_id, mpaa_rating, director,
    director_id, adult, popularity, runtime, tags, lists)

    @title = title
    @in_db = in_db
    @tmdb_id = tmdb_id
    @release_date = release_date
    @vote_average = vote_average
    @genres = genres
    @overview = overview
    @actors = actors
    @backdrop_path = backdrop_path
    @poster_path = poster_path
    @trailer = trailer
    @imdb_id = imdb_id
    @mpaa_rating = mpaa_rating
    @director = director
    @director_id = director_id
    @adult = adult
    @popularity = popularity
    @runtime = runtime
    @tags = tags
    @lists = lists

  end

  attr_accessor :title, :in_db, :tmdb_id, :release_date, :vote_average, :genres, :overview,
  :actors, :backdrop_path, :poster_path, :trailer, :imdb_id, :mpaa_rating, :director,
  :director_id, :adult, :popularity, :runtime, :tags, :lists

  def self.parse_result(result)
    @tmdb_id = result[:id]
    @in_db = Movie.exists?(tmdb_id: @tmdb_id)
      if @in_db
        @movie = Movie.find_by(tmdb_id: @tmdb_id)
      else
        self.tmdb_info(result)
      end #if in_db
    @movie
  end

    def times_seen_by(user)
      0
    end

    def self.tmdb_info(result)
        @title = result[:title]
        @release_date = Date.parse(result[:release_date]) if result[:release_date].present?
        if result[:vote_average].present?
          @vote_average = result[:vote_average].round(1)
        else
          @vote_average = 0
        end
        @genres = result[:genres].map { |genre| genre[:name] }
        @overview = result[:overview]
        @actors = result[:credits][:cast].map { |cast| cast[:name] }
        @backdrop_path = result[:backdrop_path]
        @poster_path = result[:poster_path]
        if result[:trailers][:youtube].present?
          if result[:trailers][:youtube][0][:source].present?
            @trailer = result[:trailers][:youtube][0][:source]
          else
            @trailer = nil
          end
        else
          @trailer = nil
        end
        @imdb_id = result[:imdb_id]
        @adult = result[:adult]
        @popularity = result[:popularity]
        if result[:runtime].present?
          @runtime = result[:runtime]
        else
          @runtime = 0
        end
        @tags = nil
        @lists = nil

        if result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }.present?
          if result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }.first[:certification].present?
            @mpaa_rating = result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }.first[:certification]
          else
            @mpaa_rating = "NR"
          end
        else
          @mpaa_rating = "NR"
        end

        @crew = result[:credits][:crew]
        @crew.find do |crew|
          if crew[:department] == "Directing"
            @director = crew[:name]
            @director_id = crew[:id]
          end
        end

        @movie = MovieMore.new(@title, @in_db, @tmdb_id, @release_date, @vote_average, @genres,
          @overview, @actors, @backdrop_path, @poster_path, @trailer, @imdb_id, @mpaa_rating,
          @director, @director_id, @adult, @popularity, @runtime, @tags, @lists)
    end

end
