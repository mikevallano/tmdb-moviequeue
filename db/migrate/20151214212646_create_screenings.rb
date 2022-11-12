class CreateScreenings < ActiveRecord::Migration[5.1]
  def change
    create_table :screenings do |t|
      t.references :user, index: true, foreign_key: true
      t.references :movie, index: true, foreign_key: true
      t.date :date_watched
      t.string :location_watched
      t.text :notes

      t.timestamps null: false
    end
  end
end
