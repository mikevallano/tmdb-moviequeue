# frozen_string_literal: true

class MovieSearchResult
  attr_accessor :title, :in_db, :tmdb_id, :release_date, :vote_average, :overview, :backdrop_path, :poster_path, :tags, :lists

  def initialize(title:, in_db:, tmdb_id:, release_date:, vote_average:, overview:, backdrop_path:, poster_path:)
    @title = title
    @in_db = in_db
    @tmdb_id = tmdb_id
    @release_date = release_date
    @vote_average = vote_average
    @overview = overview
    @backdrop_path = backdrop_path
    @poster_path = poster_path
    @tags = nil
    @lists = nil
  end

  def self.build_list(results)
    results.map do |result|
      new(
        title: result[:title],
        in_db: false,
        tmdb_id: result[:id],
        release_date: result[:release_date],
        vote_average: result[:vote_average]&.round(1),
        overview: result[:overview],
        backdrop_path: result[:backdrop_path],
        poster_path: result[:poster_path]
      )
    end
  end
end
