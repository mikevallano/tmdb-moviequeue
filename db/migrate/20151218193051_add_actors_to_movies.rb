class AddActorsToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :actors, :string, array:true, default: []
  end
end
