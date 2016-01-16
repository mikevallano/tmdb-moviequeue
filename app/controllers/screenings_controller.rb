class ScreeningsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie
  before_action :set_screening, only: [:show, :edit, :update, :destroy]
  before_action :redirect_url, only: :create

  # GET /screenings
  # GET /screenings.json
  def index
    @screenings = @movie.screenings.by_user(current_user)
  end

  # GET /screenings/1
  # GET /screenings/1.json
  def show
  end

  # GET /screenings/new
  def new
    @screening = @movie.screenings.by_user(current_user).new
  end

  # GET /screenings/1/edit
  def edit
  end

  # POST /screenings
  # POST /screenings.json
  def create
    @screening = current_user.screenings.new(screening_params)
    unless params[:date_watched].present?
      @screening.date_watched = DateTime.now.to_date
    end

    respond_to do |format|
      if @screening.save
        format.html { redirect_to @redirect_url, notice: 'Screening was successfully created.' }
        format.json { render :show, status: :created, location: @screening }
      else
        format.html { render :new }
        format.json { render json: @screening.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /screenings/1
  # PATCH/PUT /screenings/1.json
  def update
    respond_to do |format|
      if @screening.update(screening_params)
        format.html { redirect_to movie_path(@movie), notice: 'Screening was successfully updated.' }
        format.json { render :show, status: :ok, location: @screening }
      else
        format.html { render :edit }
        format.json { render json: @screening.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /screenings/1
  # DELETE /screenings/1.json
  def destroy
    @screening.destroy
    respond_to do |format|
      format.html { redirect_to movie_path(@movie), notice: 'Screening was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_screening
      @screening = @movie.screenings.by_user(current_user).find(params[:id])
    end

    def set_movie
      @movie = Movie.friendly.find(params[:movie_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def screening_params
      params.require(:screening).permit(:user_id, :movie_id, :date_watched, :location_watched, :notes)
    end

    def redirect_url
      @page = params[:page] if params[:page].present?
      if params[:from].present? && params[:from] == "list_show"
        @list = current_user.lists.find(params[:list_id])
        @redirect_url = user_list_path(current_user, @list, page: @page)
      elsif params[:from].present? && params[:from] == "movie_show"
        @movie = current_user.movies.find(params[:movie_id])
        @redirect_url = movie_path(@movie)
      elsif params[:from].present? && params[:from] == "movies_index"
        @redirect_url = movies_path(page: @page)
      else
        @redirect_url = movie_screenings_path(@movie)
      end
    end

end
