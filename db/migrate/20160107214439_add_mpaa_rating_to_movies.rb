class AddMpaaRatingToMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :movies, :mpaa_rating, :string
  end
end
