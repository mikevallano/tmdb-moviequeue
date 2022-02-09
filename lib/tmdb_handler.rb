# frozen_string_literal: true

module TmdbHandler
  BASE_URL = 'https://api.themoviedb.org/3'.freeze

  class TmdbHandlerError < StandardError
    def initialize(message)
      super(message)
    end
  end

  def tmdb_handler_discover_search(params)
    @actor = params[:actor]
    @actor2 = params[:actor2]
    @exact_year = params[:exact_year]
    @after_year = params[:after_year]
    @before_year = params[:before_year]
    @genre = params[:genre]
    @company = params[:company]
    @mpaa_rating = params[:mpaa_rating]
    @sort_by = params[:sort_by]
    @page = params[:page]
    @year_select = params[:year_select]

    if @actor.present?
      @actor1_url = "#{BASE_URL}/search/person?query=#{@actor}&api_key=#{ENV['tmdb_api_key']}"
      @actor1_search_result = JSON.parse(open(@actor1_url).read, symbolize_names: true)[:results]
      if !@actor1_search_result.present?
        return @not_found = "No results for '#{actor}'."
      else
        @actor1_id = @actor1_search_result.first[:id]
      end
    end

    if @actor2.present?
      @actor2_url = "#{BASE_URL}/search/person?query=#{@actor2}&api_key=#{ENV['tmdb_api_key']}"
      @actor2_search_result = JSON.parse(open(@actor2_url).read, symbolize_names: true)[:results]
      if !@actor2_search_result.present?
        return @not_found = "No results for '#{actor2}'."
      else
        @actor2_id = @actor2_search_result.first[:id]
      end
    end

    if @actor1_id.present? && @actor2_id.present?
      @people = "#{@actor1_id}, #{@actor2_id}"
    elsif @actor1_id.present?
      @people = @actor1_id
    elsif @actor2_id.present?
      @people = @actor_2_id
    else
      @people = ''
    end

    years = [@exact_year, @after_year, @before_year].compact
    if years.any?
      years = years.first
      if years == @exact_year
        @year_search = "primary_release_year=#{years}"
      elsif years == @after_year
        @year_search = "primary_release_date.gte=#{years}"
      else
        @year_search = "primary_release_date.lte=#{years}"
      end
    else
      @year_search = "primary_release_date.gte=1800-01-01"
    end
    @discover_url = "#{BASE_URL}/discover/movie?#{@year_search}&with_genres=#{@genre}&with_people=#{@people}&with_companies=#{@company}&certification_country=US&certification=#{@mpaa_rating}&sort_by=#{@sort_by}.desc&page=#{@page}&api_key=#{ENV['tmdb_api_key']}"
    @discover_results = JSON.parse(open(@discover_url).read, symbolize_names: true)[:results]
    @movies = MovieSearch.parse_results(@discover_results)
    @total_pages = JSON.parse(open(@discover_url).read, symbolize_names: true)[:total_pages]

    @page = @page.to_i
    if @page > 1
      @previous_page = @page - 1
    end
    unless @page >= @total_pages
      @next_page = @page + 1
    end

    rescue
    if @actor.present?
      unless @actor1_search_result.present?
        @not_found = "No results for '#{@actor}'."
      end
    end
    if @actor2.present?
      unless @actor2_search_result.present?
        @not_found = "No results for '#{@actor2}'."
      end
    end

  end #discover search
end
