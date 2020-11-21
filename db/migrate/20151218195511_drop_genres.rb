class DropGenres < ActiveRecord::Migration
  def change
    drop_table :genre_movies if table_exists?(:genre_movies)
  end
end
