class DropGenres < ActiveRecord::Migration[5.1]
  def change
    drop_table :genre_movies if table_exists?(:genre_movies)
  end
end
