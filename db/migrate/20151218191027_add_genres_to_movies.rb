class AddGenresToMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :movies, :genres, :string, array:true, default: []
  end
end
