# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @movie = GuaranteedMovie.find_or_create(create_params[:tmdb_id])

    listing = Listing.new(
      create_params.except(:tmdb_id).merge(movie_id: @movie.id, user_id: current_user.id)
    )

    respond_to do |format|
      begin
        if listing.save
          format.turbo_stream
          format.html { redirect_to user_list_path(listing.list.owner, listing.list), notice: 'added to your list.' }
          format.json { render :show, status: :created, location: listing }
        else
          format.turbo_stream
          format.html { redirect_to movie_path(@movie), notice: 'error.' }
          format.json { render json: listing.errors, status: :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotUnique
        format.turbo_stream { head :ok }
        format.html { redirect_to user_list_path(listing.list.owner, listing.list)}
        format.json { head :ok }
      end
    end
  end

  def update
    @listing = Listing.find_by(list_id: update_params[:list_id], movie_id: update_params[:movie_id])
    # TODO: refactor to be more efficient
    unless current_user.all_listings.include?(@listing)
      redirect_to user_lists_path(current_user), notice: 'not your listing.' and return
    end
    @priority = params[:priority]
    @movie = Movie.friendly.find(params[:movie_id])
    @list = List.friendly.find(params[:list_id])
    respond_to do |format|
      if @listing.update!(priority: @priority)
        format.turbo_stream
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
    # TODO: refactor this to be more efficient
    unless current_user.all_listings.include?(@listing)
      redirect_to user_lists_path(current_user), notice: 'not your listing.' and return
    end
    @movie = Movie.find(params[:movie_id])
    @listing.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user_list_path(@listing.list.owner, @listing.list), notice: 'Movie was removed from list.' }
    end
  end

  private

  def create_params
    params.require(:listing).permit(:list_id, :tmdb_id, :priority)
  end

  def update_params
    params.permit(:list_id, :movie_id, :priority)
  end

end
