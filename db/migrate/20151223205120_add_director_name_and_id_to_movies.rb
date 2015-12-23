class AddDirectorNameAndIdToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :director, :string
    add_column :movies, :director_id, :integer
  end
end
