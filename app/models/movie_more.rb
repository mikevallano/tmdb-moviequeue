# frozen_string_literal: true

class MovieMore
  attr_accessor :actors, :adult, :backdrop_path, :crew, :director, :director_id, :genres, :imdb_id, :in_db, :lists, :mpaa_rating, :overview, :popularity, :poster_path, :production_companies, :release_date, :runtime, :tags, :title, :tmdb_id, :trailer, :vote_average

  def initialize(args)
    @actors = args[:actors]
    @adult = args[:adult]
    @backdrop_path = args[:backdrop_path]
    @crew = args[:crew]
    @director = args[:director]
    @director_id = args[:director_id]
    @lists = args[:lists]
    @imdb_id = args[:imdb_id]
    @in_db = args[:in_db]
    @genres = args[:genres]
    @overview = args[:overview]
    @release_date = args[:release_date]
    @mpaa_rating = args[:mpaa_rating]
    @popularity = args[:popularity]
    @poster_path = args[:poster_path]
    @production_companies = args[:production_companies]
    @runtime = args[:runtime]
    @tags = args[:tags]
    @title = args[:title]
    @tmdb_id = args[:tmdb_id]
    @trailer = args[:trailer]
    @vote_average = args[:vote_average]
  end

  def self.parse_result(result)
    Movie.find_by(tmdb_id: result[:id]) || tmdb_info(result)
  end

  def times_seen_by(user)
    0
  end

  def self.tmdb_info(result)
    release_date = Date.parse(result[:release_date]) if result[:release_date].present?
    vote_average = result[:vote_average].present? ? result[:vote_average].round(1) : 0
    runtime = result[:runtime].presence || 0

    trailer = if result[:trailers][:youtube].present?
      result[:trailers][:youtube][0][:source].presence
    end

    us_movie_releases = result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }
    mpaa_rating = us_movie_releases.present? && us_movie_releases.first[:certification].present? ? us_movie_releases.first[:certification] : 'NR'
    first_director = result[:credits][:crew].find {|crew| crew[:department] == 'Directing'}.presence || {}
    new(
      actors: result[:credits][:cast].map { |cast| cast[:name] },
      adult: result[:adult],
      backdrop_path: result[:backdrop_path],
      crew: result[:credits][:crew],
      director: first_director[:name],
      director_id: first_director[:id],
      genres: result[:genres].map { |genre| genre[:name] },
      imdb_id: result[:imdb_id],
      in_db: Movie.exists?(tmdb_id: result[:tmdb_id]),
      lists: nil,
      mpaa_rating: mpaa_rating,
      overview: result[:overview],
      popularity: result[:popularity],
      poster_path: result[:poster_path],
      production_companies: result[:production_companies],
      release_date: release_date,
      runtime: runtime,
      tags: nil,
      title: result[:title],
      tmdb_id: result[:id],
      trailer: trailer,
      vote_average: vote_average
    )
  end
end
