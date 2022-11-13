class AddActorsToMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :movies, :actors, :string, array:true, default: []
  end
end
