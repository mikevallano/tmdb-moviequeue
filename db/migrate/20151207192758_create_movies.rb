class CreateMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :tmdb_id
      t.string :imdb_id
      t.string :backdrop_path
      t.string :poster_path
      t.date :release_date
      t.text :overview
      t.string :trailer
      t.float :vote_average
      t.float :popularity

      t.timestamps null: false
    end
  end
end
