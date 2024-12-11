class CreateTVSeriesViewings < ActiveRecord::Migration[7.1]
  def change
    create_table :tv_series_viewings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.string :show_id, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.timestamps
    end

    add_index :tv_series_viewings, :show_id
    add_index :tv_series_viewings, :ended_at
  end
end
