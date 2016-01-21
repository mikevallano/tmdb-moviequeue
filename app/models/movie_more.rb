class MovieMore
  def initialize(title, in_db, tmdb_id, release_date, vote_average, genres, overview, actors, backdrop_path, poster_path, trailer, imdb_id, mpaa_rating, director, director_id, adult, popularity, runtime)

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

  end

  attr_accessor :title, :in_db, :tmdb_id, :release_date, :vote_average, :genres, :overview, :actors, :backdrop_path, :poster_path, :trailer, :imdb_id, :mpaa_rating, :director, :director_id, :adult, :popularity, :runtime

  def self.parse_result(result)
    @tmdb_id = result[:id]
    @in_db = Movie.exists?(tmdb_id: @tmdb_id)
      if @in_db
        @movie = Movie.find_by(tmdb_id: @tmdb_id)
      else
        @title = result[:title]
        @release_date = result[:release_date]
        @vote_average = result[:vote_average].round(1)
        @genres = result[:genres].map { |genre| genre[:name] }
        @overview = result[:overview]
        @actors = result[:credits][:cast].map { |cast| cast[:name] }
        @backdrop_path = result[:backdrop_path]
        @poster_path = result[:poster_path]
        @youtube_trailers = result[:trailers][:youtube]
        @trailer = result[:trailers][:youtube][0][:source] if @youtube_trailers.present?
        @imdb_id = result[:imdb_id]
        @adult = result[:adult]
        @popularity = result[:popularity]
        @runtime = result[:runtime]

        if result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }.present?
          @mpaa_rating = result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }.first[:certification]
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

        @movie = MovieMore.new(@title, @in_db, @tmdb_id, @release_date, @vote_average, @genres, @overview, @actors, @backdrop_path, @poster_path, @trailer, @imdb_id, @mpaa_rating, @director, @director_id, @adult, @popularity, @runtime)
      end #if in_db
    @movie
  end

end


