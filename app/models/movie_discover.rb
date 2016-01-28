class MovieDiscover
  def initialize(exact_year, after_year, before_year, genre, actor, actor2, company, mpaa_rating, sort_by, page)

    @exact_year = exact_year
    @after_year = after_year
    @before_year = before_year
    @genre = genre
    @actor = actor
    @actor2 = actor2
    @company = company
    @mpaa_rating = mpaa_rating
    @sort_by = sort_by
    @page = page
  end

  attr_accessor :exact_year, :after_year, :before_year, :genre, :actor, :actor2, :company, :mpaa_rating, :sort_by, :page

  def self.parse_params(params)
    @year_select = params[:year_select]

    @year = params[:date][:year] if params[:date].present?

    unless @year.present?
      @year_select = nil
    end

    if @year_select.present?
      if @year_select == "exact"
        @exact_year = @year
      elsif @year_select == "after"
        @after_year = "#{@year}-01-01"
      elsif @year_select == "before"
        @before_year = "#{@year}-01-01"
      end
    else #if @year_select.present?
      @exact_year = @year if @year.present?
      @after_year = nil
      @before_year = nil
    end #if @year_select.present?

    @genre = params[:genre] if params[:genre].present?
    @actor = params[:actor] if params[:actor].present?
    @actor2 = params[:actor2] if params[:actor2].present?
    @company = params[:company] if params[:company].present?
    @mpaa_rating = params[:mpaa_rating] if params[:mpaa_rating].present?

    if params[:sort_by].present?
      @sort_by = params[:sort_by]
    else
      @sort_by = "revenue"
    end #sort_by

    if params[:page]
      @page = params[:page]
    else
      @page = 1
    end #pagination

    MovieDiscover.new(@exact_year, @after_year, @before_year, @genre, @actor, @actor2,
      @company, @mpaa_rating, @sort_by, @page)

  end #parase params

end #final


