class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :update, :destroy]
  before_action :restrict_list_access, only: [:show, :edit, :update, :destroy]

  # GET /lists
  # GET /lists.json
  def index
    @lists = current_user.all_lists
  end

  # GET /lists/1
  # GET /lists/1.json
  def show
    if request.path != user_list_path(@list.owner, @list)
      return redirect_to user_list_path(@list.owner, @list), :status => :moved_permanently
    end
  end

  # GET /lists/new
  def new
    @list = List.new
  end

  # GET /lists/1/edit
  def edit
  end

  # POST /lists
  # POST /lists.json
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

  # PATCH/PUT /lists/1
  # PATCH/PUT /lists/1.json
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

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to user_lists_url(current_user), notice: 'List was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @owner = User.friendly.find(params[:user_id])
      @list = List.find_by(owner: @owner, slug: params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
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
