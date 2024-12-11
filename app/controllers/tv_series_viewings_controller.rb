class TVSeriesViewingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @viewings = current_user.tv_series_viewings
  end

  def create
    @viewing = current_user.tv_series_viewings.create(
      title: params[:title],
      show_id: params[:show_id],
      url: tv_series_path(show_id: params[:show_id]),
      started_at: Time.current
    )

    # respond_to do |format|
    #   if viewing.save
    #     format.turbo_stream {}
    #     format.html { redirect_to tv_series_path, notice: 'Added to Currently Watching List.' }
    #   end
    # end
  end

  def update
    @viewing = current_user.tv_series_viewings.active.find_by(show_id: params[:show_id])
    binding.pry
    @viewing.update(ended_at: Time.current)
  end

  # def create
  #   @screening = current_user.screenings.new(screening_params)
  #   @screening.movie_id = @movie.id

  #   respond_to do |format|
  #     if @screening.save
  #       format.turbo_stream {}
  #       format.html { redirect_to movie_screenings_path(@movie), notice: 'Screening was successfully created.' }
  #       format.json { render :show, status: :created, location: @screening }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @screening.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # def update
  #   respond_to do |format|
  #     if @screening.update(screening_params)
  #       format.html { redirect_to movie_screenings_path(@movie), notice: 'Screening was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @screening }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @screening.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  
  def tv_series_viewings_params
    binding.pry
  end
end
