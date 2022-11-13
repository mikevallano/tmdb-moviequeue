class AddDirectorNameAndIdToMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :movies, :director, :string
    add_column :movies, :director_id, :integer
  end
end
