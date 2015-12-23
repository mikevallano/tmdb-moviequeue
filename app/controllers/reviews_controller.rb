class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_action :restrict_reviews_access, only: [:show, :edit, :update, :destroy]


  def index
    @reviews = @movie.reviews
  end

  def show
  end

  def new
    if @movie.reviews.by_user(current_user).present?
      redirect_to movie_review_path(@movie, @movie.reviews.by_user(current_user).first), notice: "You've already reviewed this movie"
    else
      @review = current_user.reviews.new
    end
  end

  def edit
  end

  def create
    @review = Review.new(review_params)

    respond_to do |format|
      if @review.save
        format.html { redirect_to movie_path(@movie), notice: 'Review was successfully created.' }
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to movie_path(@movie), notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to movie_url(@movie), notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_review
      @review = Review.find(params[:id])
    end

    def set_movie
      @movie = Movie.friendly.find(params[:movie_id])
    end

    def review_params
      params.require(:review).permit(:user_id, :movie_id, :body)
    end

    def restrict_reviews_access
      unless current_user.reviews.include?(@review)
        redirect_to movie_path(@movie), notice: "That's not your review"
      end
    end
end
