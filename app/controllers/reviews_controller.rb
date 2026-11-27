class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_action :restrict_reviews_access, only: [:show, :edit, :update, :destroy]


  def index
    @reviews = @movie.reviews.order("created_at DESC")
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

    if @review.save
      redirect_to movie_path(@movie), notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def update
    if @review.update(review_params)
      redirect_to movie_path(@movie), notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to movie_url(@movie), status: :see_other, notice: 'Review was successfully destroyed.'
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
