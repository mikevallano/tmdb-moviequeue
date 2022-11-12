class DropGenreTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :genres if table_exists?(:genres)
  end
end
