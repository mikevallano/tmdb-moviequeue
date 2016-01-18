class ScreeningsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie
  before_action :set_screening, only: [:show, :edit, :update, :destroy]
  before_action :redirect_url, only: :create

  def index
    @screenings = @movie.screenings.by_user(current_user)
  end

  def show
  end

  def new
    @screening = @movie.screenings.by_user(current_user).new
  end

  def edit
  end

  def create
    @screening = current_user.screenings.new(screening_params)
    unless params[:date_watched].present?
      @screening.date_watched = DateTime.now.to_date
    end

    @movies = current_user.all_movies
    @movie = Movie.friendly.find(params[:movie_id])

    respond_to do |format|
      if @screening.save
        format.html { redirect_to @redirect_url, notice: 'Screening was successfully created.' }
        format.json { render :show, status: :created, location: @screening }
        format.js {}
      else
        format.html { render :new }
        format.json { render json: @screening.errors, status: :unprocessable_entity }
      end
    end
  end

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

  def destroy
    @screening.destroy
    respond_to do |format|
      format.html { redirect_to movie_path(@movie), notice: 'Screening was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_screening
      @screening = @movie.screenings.by_user(current_user).find(params[:id])
    end

    def set_movie
      @movie = Movie.friendly.find(params[:movie_id])
    end

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
