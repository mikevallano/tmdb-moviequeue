class MovieSearch
  def initialize(title, in_db, tmdb_id, release_date, vote_average, overview, backdrop_path, poster_path, tags, lists)

    @title = title
    @in_db = in_db
    @tmdb_id = tmdb_id
    @release_date = release_date
    @vote_average = vote_average
    @overview = overview
    @backdrop_path = backdrop_path
    @poster_path = poster_path
    @tags = tags
    @lists = lists
  end

  attr_accessor :title, :in_db, :tmdb_id, :release_date, :vote_average, :overview, :backdrop_path, :poster_path, :tags, :lists

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
          @vote_average = result[:vote_average]&.round(1)
          @overview = result[:overview]
          @backdrop_path = result[:backdrop_path]
          @poster_path = result[:poster_path]
          @tags = nil
          @lists = nil

          @movie = MovieSearch.new(@title, @in_db, @tmdb_id, @release_date, @vote_average, @overview, @backdrop_path, @poster_path, @tags, @lists)
          @movies << @movie
        end
    end #loop
    @movies
  end

end
