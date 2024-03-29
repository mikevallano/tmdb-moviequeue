# frozen_string_literal: true

class ScreeningsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie, only: [:index, :new, :edit, :create, :update, :destroy]
  before_action :set_screening, only: [:edit, :update, :destroy]

  def index
    @screenings = @movie.screenings.by_user(current_user)
  end

  def new
    default_params = {
      date_watched: Date.current,
      location_watched: current_user.default_location
    }
    @screening = @movie.screenings
                       .by_user(current_user)
                       .new(default_params)
  end

  def edit
  end

  def create
    @screening = current_user.screenings.new(screening_params)
    @screening.movie_id = @movie.id

    respond_to do |format|
      if @screening.save
        format.turbo_stream {}
        format.html { redirect_to movie_screenings_path(@movie), notice: 'Screening was successfully created.' }
        format.json { render :show, status: :created, location: @screening }
      else
        format.html { render :new }
        format.json { render json: @screening.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @screening.update(screening_params)
        format.html { redirect_to movie_screenings_path(@movie), notice: 'Screening was successfully updated.' }
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
      format.html { redirect_to movie_screenings_path(@movie), notice: 'Screening was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_screening
    @screening = @movie.screenings.by_user(current_user).find(params[:id])
  end

  def set_movie
    if params[:tmdb_id].present?
      @movie = GuaranteedMovie.find_or_create(params[:tmdb_id])
    else
      @movie = Movie.friendly.find(params[:movie_id])
    end
  end

  def screening_params
    params.require(:screening).permit(:user_id, :movie_id, :date_watched, :location_watched, :notes, :tmdb_id)
  end
end
