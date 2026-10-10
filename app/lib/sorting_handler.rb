module SortingHandler

  def list_sort_handler(sort_by, member = nil)
    @sort_by = sort_by
    @member = member
    if @member.present?
      @user = User.find(@member)
    end

    #this determines which params will show the sub-sort by list member
    @watched_sorts = ["watched movies", "unwatched movies", "only show unwatched",
      "only show watched", "recently watched"]

    case @sort_by
    when "title"
      @movies = @list.movies.by_title
    when "shortest runtime"
      @movies = @list.movies.by_shortest_runtime
    when "longest runtime"
      @movies = @list.movies.by_longest_runtime
    when "newest release"
      @movies = @list.movies.by_recent_release_date
    when "vote average"
      @movies = @list.movies.by_highest_vote_average
    when "recently added to list"
      @movies = @list.movies.by_recently_added(@list)
    when "watched movies"
      if @member.present?
        @movies = @list.movies.by_watched_by_user(@list, @user)
      else
        @movies = @list.movies.by_watched_by_user(@list, current_user)
      end
    when "unwatched movies"
      if @member.present?
        @movies = @list.movies.by_unwatched_by_user(@list, @user)
      else
        @movies = @list.movies.by_unwatched_by_user(@list, current_user)
      end
    when "only show unwatched"
      if @member.present?
        @movies = @list.movies.unwatched_by_user(@user)
      else
        @movies = @list.movies.unwatched_by_user(current_user)
      end
    when "only show watched"
      if @member.present?
        @movies = @list.movies.watched_by_user(@user)
      else
        @movies = @list.movies.watched_by_user(current_user)
      end
    when "highest priority"
      @movies = @list.movies.by_highest_priority(@list)
    when "recently watched"
      if @member.present?
        @movies = @list.movies.by_recently_watched_by_user(@user)
      else
        @movies = @list.movies.by_recently_watched_by_user(current_user)
      end
    when MovieDataService::STREAMING_SORT_OPTION
      @movies = @list.movies.default_list_order(@list)
      if streaming_filter_available?
        # Only the current page is checked (one TMDB request per movie). Pagination stays on the
        # unfiltered pages, so the next page link shows the next page filtered.
        # from_page is sent by the sort form (from the default order) so selecting the filter keeps the page being viewed.
        @pagination_movies = @movies.paginate(page: params[:page].presence || params[:from_page].presence, per_page: 20).load
        availability = UserStreamingServiceProviderDataService.check_availability_for_movies(user: current_user, movies: @pagination_movies)
        if availability.failed_ids.any?
          failed_titles = @pagination_movies.select { |movie| availability.failed_ids.include?(movie.id) }.map(&:title)
          flash.now[:alert] = "Couldn't check streaming availability for: #{failed_titles.to_sentence}"
        end
        @movies = @pagination_movies.select { |movie| availability.available_ids.include?(movie.id) }
      end
    end #case
    @movies = @movies.paginate(:page => params[:page], per_page: 20) unless @pagination_movies
  end #list sort handler

  def movies_index_sort_handler(sort_by)
    @sort_by = sort_by

    case @sort_by
    when "title"
      @movies = current_user.all_movies_by_title
    when "shortest runtime"
      @movies = current_user.all_movies_by_shortest_runtime
    when "longest runtime"
      @movies = current_user.all_movies_by_longest_runtime
    when "newest release"
      @movies = current_user.all_movies_by_recent_release_date
    when "vote average"
      @movies = current_user.all_movies_by_highest_vote_average
    when "recently watched"
      @movies = current_user.all_movies_by_recently_watched
    when "watched movies"
      @movies = current_user.all_movies_by_watched
    when "unwatched movies"
      @movies = @movies = current_user.all_movies_by_unwatched
    when "only show unwatched"
      @movies = Movie.unwatched_by_user(current_user)
    when "only show watched"
      @movies = Movie.watched_by_user(current_user)
    when "movies not on a list"
      @movies = current_user.all_movies_not_on_a_list
    else
      @movies = current_user.all_movies
    end #case

    @movies = @movies.paginate(:page => params[:page], per_page: 20)
  end #movies index sort handler

end #module
