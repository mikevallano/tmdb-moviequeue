class DropGenres < ActiveRecord::Migration
  def change
    drop_table :genre_movies
  end
end
