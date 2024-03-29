class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie
  before_action :set_rating, only: [:show, :edit, :update, :destroy]
  before_action :restrict_ratings_access, only: [:show, :edit, :update, :destroy]

  def index
    @ratings = @movie.ratings.order("created_at DESC")
  end

  def show
  end

  def new
    if @movie.ratings.by_user(current_user).present?
      redirect_to movie_rating_path(@movie, @movie.ratings.by_user(current_user).first), notice: "You've already rated this movie"
    else
      @rating = current_user.ratings.new
    end
  end

  def edit
  end

  def create
    @rating = Rating.new(rating_params)
    @frompage = params[:from] if params[:from].present?
    @movie = Movie.friendly.find(params[:movie_id])

    respond_to do |format|
      if @rating.save
        format.turbo_stream
        format.html { redirect_to movie_path(@movie), notice: 'Rating was successfully created.' }
        format.json { render :show, status: :created, location: @rating }
      else
        format.html { render :new }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @rating.update(rating_params)
        format.html { redirect_to movie_path(@movie), notice: 'Rating was successfully updated.' }
        format.json { render :show, status: :ok, location: @rating }
      else
        format.html { render :edit }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @rating.destroy
    respond_to do |format|
      format.html { redirect_to movie_path(@movie), notice: 'Rating was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_rating
      @rating = Rating.find(params[:id])
    end

    def set_movie
      @movie = Movie.friendly.find(params[:movie_id])
    end

    def rating_params
      params.require(:rating).permit(:user_id, :movie_id, :value)
    end

    def restrict_ratings_access
      unless current_user.ratings.include?(@rating)
        redirect_to movie_path(@movie), notice: "That's not your rating"
      end
    end

end
