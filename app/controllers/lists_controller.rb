class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :update, :destroy]
  before_action :restrict_list_access, only: [:show, :edit, :update, :destroy]

  include SortingHandler

  helper_method :streaming_filter_available?

  def public
    @lists = List.public_lists.paginate(page: params[:page])
  end

  def index
    @owner = User.friendly.find(params[:user_id])
    unless @owner == current_user
      redirect_to user_lists_path(current_user), notice: "Those aren't your lists"
    end
    @lists = current_user.all_lists.includes(:owner)
    @list_movie_count = Listing.where(list: @lists).group(:list_id).count
  end

  def show
    if request.path != user_list_path(@list.owner, @list)
      return redirect_to user_list_path(@list.owner, @list), status: :moved_permanently
    end

    @sort_by = params[:sort_by]
    @member = params[:member]
    if @sort_by.present?
      list_sort_handler(@sort_by, @member)
    else
      @movies = @list.movies.default_list_order(@list).paginate(page: params[:page], per_page: 20)
    end
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

    if @list.save
      redirect_to user_lists_path(current_user), notice: 'List was successfully created.'
    else
      render :new
    end
  end

  def update
    if @list.update(list_params)
      redirect_to user_lists_path(current_user), notice: 'List was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    unless @list.owner == current_user
      redirect_to user_list_path(@list.owner, @list), status: :see_other, notice: "Only list owners can delete lists." and return
    end
    @list.destroy
    redirect_to user_lists_url(current_user), status: :see_other, notice: 'List was successfully destroyed.'
  end

  private
    def set_list
      @owner = User.friendly.find(params[:user_id])
      @list = List.find_by(owner: @owner, slug: params[:id] )
    end

    def list_params
      params.require(:list).permit(:owner_id, :name, :is_public, :description)
    end

    def streaming_filter_available?
      return @streaming_filter_available if defined?(@streaming_filter_available)

      @streaming_filter_available = current_user.admin? && current_user.streaming_service_providers.any?
    end

    def restrict_list_access
      if @list.is_public == false
        unless current_user.all_lists.include?(@list)
          redirect_to user_lists_path(current_user), notice: "That's not your list"
        end
      end
    end
end
