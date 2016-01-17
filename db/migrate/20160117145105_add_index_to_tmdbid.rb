class AddIndexToTmdbid < ActiveRecord::Migration
  def change
    add_index :movies, :tmdb_id
  end
end