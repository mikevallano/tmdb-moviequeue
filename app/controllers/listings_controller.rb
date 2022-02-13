# frozen_string_literal: true

class ListingsController < ApplicationController
  include TmdbHandler

  before_action :authenticate_user!

  def create
    @from = params[:from]
    @movie = GuaranteedMovie.find_or_create(params[:tmdb_id])

    listing = current_user.listings.new(listing_params)
    listing.movie_id = @movie.id
    listing.user_id = current_user.id

    respond_to do |format|
      if listing.save
        format.js {}
        format.html { redirect_to user_list_path(listing.list.owner, listing.list), notice: 'added to your list.' }
        format.json { render :show, status: :created, location: listing }
      else
        format.html { redirect_to movie_path(@movie), notice: 'error.' }
        format.json { render json: listing.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @listing = Listing.find_by("list_id = ? AND movie_id = ?", params[:list_id], params[:movie_id])
    unless current_user.all_listings.include?(@listing)
      redirect_to user_lists_path(current_user), notice: 'not your listing.' and return
    end
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
    @listing = Listing.find_by("list_id = ? AND movie_id = ?", params[:list_id], params[:movie_id])
    unless current_user.all_listings.include?(@listing)
      redirect_to user_lists_path(current_user), notice: 'not your listing.' and return
    end
    @movie = Movie.find(params[:movie_id])
    @listing.destroy
    respond_to do |format|
      format.js {}
      format.html { redirect_to user_list_path(@listing.list.owner, @listing.list), notice: 'Movie was removed from list.' }
      format.json { head :no_content }
    end
  end

  private

  def listing_params
    params.require(:listing).permit(:list_id, :movie_id, :priority, :user_id)
  end

end
