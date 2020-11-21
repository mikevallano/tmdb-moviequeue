class DropGenreTable < ActiveRecord::Migration
  def change
    drop_table :genres if table_exists?(:genres)
  end
end
