class ListingsController < ApplicationController
  before_action :authenticate_user!

  include TmdbHandler

  def create
    @listing = Listing.new(listing_params)
    @tmdb_id = params[:tmdb_id]
    @user_id = params[:user_id]

    unless Movie.exists?(tmdb_id: @tmdb_id)
      tmdb_handler_add_movie(@tmdb_id)
    end

    @movie = Movie.find_by_tmdb_id(@tmdb_id)
    @listing.movie_id = @movie.id
    @listing.user_id = @user_id

    #TODO: clean this up
    unless params[:priority].present?
      @listing.priority = 5
    end

    @user = User.friendly.find(@user_id)
    @movies = current_user.all_movies
    respond_to do |format|
      if @listing.save
        format.js {}
        format.html { redirect_to user_list_path(@user, List.friendly.find(@listing.list.id)), notice: 'added to your list.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @listing = current_user.listings.find_by("list_id = ? AND movie_id = ?", params[:list_id], params[:movie_id])
    @priority = params[:priority]
    @movies = @movies = current_user.all_movies
    @movie = Movie.friendly.find(params[:movie_id])
    @list = List.friendly.find(params[:list_id])
    respond_to do |format|
      if @listing.update_attributes(:priority => @priority)
        format.js {}
        format.html { redirect_to user_list_path(@listing.list.owner, @listing.list), notice: 'Priority added.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { redirect_to user_list_path(@listing.list.owner, @listing.list) }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @listing = current_user.listings.find_by("list_id = ? AND movie_id = ?", params[:list_id], params[:movie_id])
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to user_list_path(@listing.list.owner, @listing.list), notice: 'Movie was removed from list.' }
      format.json { head :no_content }
    end
  end

  private

  def listing_params
    params.require(:listing).permit(:list_id, :movie_id, :priority)
  end

end