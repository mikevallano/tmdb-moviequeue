module SearchParamParser

  def parse_params(params)
    @passed_params = params

    @year_select = @passed_params[:year_select]

    @year = @passed_params[:year]

    if @year.present?
      if @year_select.present?
        if @year_select == "exact"
          @passed_params[:exact_year] = @year
        elsif @year_select == "after"
          @passed_params[:after_year] = "#{@year}-12-31"
        elsif @year_select == "before"
          @passed_params[:before_year] = "#{@year}-01-01"
        end
      else
        @passed_params[:exact_year] = @year
      end
    end

    if !@passed_params[:page]
      @passed_params[:page] = 1
    end #pagination

    if !@passed_params.keys.include?('sort_by')
      @passed_params[:sort_by] = "revenue"
    end

  end #parase params

end #final
