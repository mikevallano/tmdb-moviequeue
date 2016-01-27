module SortingHandler

  def list_sort_handler(sort_by, member = nil)
    @sort_by = sort_by
    @member = member
    if @member.present?
      @user = User.find(@member)
    end
    @watched_sorts = ["watched movies", "unwatched movies", "only show unwatched", "only show watched"]

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
    end #case
    @movies = @movies.paginate(:page => params[:page], per_page: 20)
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
      @movies = current_user.watched_movies
    when "movies not on a list"
      @movies = current_user.all_movies_not_on_a_list
    else
      @movies = current_user.all_movies
    end #case

    @movies = @movies.paginate(:page => params[:page], per_page: 20)
  end #movies index sort handler

end #module