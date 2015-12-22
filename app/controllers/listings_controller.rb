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

    respond_to do |format|
      if @listing.save
        format.html { redirect_to movies_path, notice: 'added to your list.' }
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
    respond_to do |format|
      if @listing.update_attributes(:priority => @priority)
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