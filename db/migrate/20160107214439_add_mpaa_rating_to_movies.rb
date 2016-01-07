class AddMpaaRatingToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :mpaa_rating, :string
  end
end
