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
    if current_user.all_lists.include?(@list)
      if request.path != user_list_path(@list.owner, @list)
        return redirect_to user_list_path(@list.owner, @list), :status => :moved_permanently
      end
      @movies = @list.movies.paginate(:page => params[:page])
    else
      @movies = @list.movies.paginate(:page => params[:page])
      render :public_show
    end

  end

  def new
    @list = List.new
  end

  def edit
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
