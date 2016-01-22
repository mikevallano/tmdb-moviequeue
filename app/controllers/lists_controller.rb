class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :update, :destroy]
  before_action :restrict_list_access, only: [:show, :edit, :update, :destroy]

  def public
    @lists = List.public_lists.paginate(:page => params[:page])
  end

  def index
    @owner = User.friendly.find(params[:user_id])
    unless @owner == current_user
      redirect_to user_lists_path(current_user), notice: "Those aren't your lists"
    end
    @lists = current_user.all_lists
  end

  def show
    if request.path != user_list_path(@list.owner, @list)
      return redirect_to user_list_path(@list.owner, @list), :status => :moved_permanently
    end

    unless current_user.all_lists.include?(@list)
      @movies = @list.movies.paginate(:page => params[:page], per_page: 20)
      render :public_show
    end
    # @movies = @list.movies.paginate(:page => params[:page])

    [ ["highest priority", "highest priority"], ["title", "title"], ["shortest runtime", "shortest runtime"], ["longest runtime", "longest runtime"], ["newest release", "newest release"], ["vote average", "vote average"], ["recently added to list", "recently added to list"], ["watched movies", "watched movies"], ["unwatched movies", "unwatched movies"]  ]

    @sort_by = params[:sort_by]
    @watched_by = params[:watched_by]
      if @sort_by.present?
        case @sort_by
        when "title"
          @movies = @list.movies.by_title.paginate(:page => params[:page], per_page: 20)
        when "shortest runtime"
          @movies = @list.movies.by_shortest_runtime.paginate(:page => params[:page], per_page: 20)
        when "longest runtime"
          @movies = @list.movies.by_longest_runtime.paginate(:page => params[:page], per_page: 20)
        when "newest release"
          @movies = @list.movies.by_recent_release_date.paginate(:page => params[:page], per_page: 20)
        when "vote average"
          @movies = @list.movies.by_highest_vote_average.paginate(:page => params[:page], per_page: 20)
        when "recently added to list"
          @movies = @list.movies.by_recently_added(@list).paginate(:page => params[:page], per_page: 20)
        when "watched movies"
          if @watched_by.present?
            @user = User.find(@watched_by)
            @movies = @list.movies.by_watched_by_user(@list, @user).paginate(:page => params[:page], per_page: 20)
          else
            @movies = @list.movies.by_watched_by_user(@list, current_user).paginate(:page => params[:page], per_page: 20)
          end
        when "unwatched movies"
          @movies = @list.movies.by_unwatched_by_user(@list, current_user).paginate(:page => params[:page], per_page: 20)
        when "highest priority"
           @movies = @list.movies.by_highest_priority(@list).paginate(:page => params[:page], per_page: 20)
        end
      else
        @movies = @list.movies.by_highest_priority(@list).paginate(:page => params[:page], per_page: 20)
      end
    # @movies = @list.movies.watched_by_user(current_user) #this doesn't sort, but returns only matching movies
    # could also do params[:user_id] with a dropdown of members
    # @movies = @list.movies.unwatched_by_user(current_user)

    # @movies = @list.movies.by_watched_by_members(@list).paginate(:page => params[:page]) #not working


  end

  def new
    @list = List.new
  end

  def edit
    unless @list.owner == current_user
      redirect_to user_list_path(@list.owner, @list), notice: "Only list owners can edit lists."
    end
  end

  def create
    @list = List.new(list_params)

    respond_to do |format|
      if @list.save
        format.html { redirect_to user_lists_path(current_user), notice: 'List was successfully created.' }
        format.json { render :show, status: :created, location: @list }
      else
        format.html { render :new }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @list.update(list_params)
        format.html { redirect_to user_lists_path(current_user), notice: 'List was successfully updated.' }
        format.json { render :show, status: :ok, location: @list }
      else
        format.html { render :edit }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    unless @list.owner == current_user
      redirect_to user_list_path(@list.owner, @list), notice: "Only list owners can delete lists." and return
    end
    @list.destroy
    respond_to do |format|
      format.html { redirect_to user_lists_url(current_user), notice: 'List was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_list
      @owner = User.friendly.find(params[:user_id])
      @list = List.find_by(owner: @owner, slug: params[:id] )
    end

    def list_params
      params.require(:list).permit(:owner_id, :name, :is_public)
    end

    def restrict_list_access
      if @list.is_public == false
        unless current_user.all_lists.include?(@list)
          redirect_to user_lists_path(current_user), notice: "That's not your list"
        end
      end
    end
end
