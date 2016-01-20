class MovieSearch
  def initialize(title, in_db, tmdb_id, release_date, vote_average, overview, backdrop_path, poster_path)

    @title = title
    @in_db = in_db
    @tmdb_id = tmdb_id
    @release_date = release_date
    @vote_average = vote_average
    @overview = overview
    @backdrop_path = backdrop_path
    @poster_path = poster_path
  end

  attr_accessor :title, :in_db, :tmdb_id, :release_date, :vote_average, :overview, :backdrop_path, :poster_path

  def self.parse_results(json)
    @movies = []
    json.each do |result|
      @tmdb_id = result[:id]
      @in_db = Movie.exists?(tmdb_id: @tmdb_id)
        if @in_db
          @movies << Movie.find_by(tmdb_id: @tmdb_id)
        else
          @title = result[:title]
          @release_date = result[:release_date]
          @vote_average = result[:vote_average].round(1)
          # @genre_list = @result[:genres]
          # @genres = result[:genres].map { |genre| genre[:name] }
          @overview = result[:overview]
          # @actors = result[:credits][:cast].map { |cast| cast[:name] }
          @backdrop_path = result[:backdrop_path]
          @poster_path = result[:poster_path]
          # @youtube_trailers = result[:trailers][:youtube]
          # @trailer = result[:trailers][:youtube][0][:source] if @youtube_trailers.present?
          # if result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }.present?
          #   @mpaa_rating = result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }.first[:certification]
          # else
          #   @mpaa_rating = "NR"
          # end
          # @crew = result[:credits][:crew]
          # @crew.find do |crew|
          #   if crew[:department] == "Directing"
          #     @director = crew[:name]
          #     @director_id = crew[:id]
          #   end
          # end

          @movie = MovieSearch.new(@title, @in_db, @tmdb_id, @release_date, @vote_average, @overview, @backdrop_path, @poster_path)
          @movies << @movie
        end
    end #loop
    @movies
  end

end

