class RemoveRedundantListingIndexes < ActiveRecord::Migration[7.1]
  def up
    remove_index :listings, :movie_id if index_exists?(:listings, :movie_id)
    remove_index :listings, :list_id if index_exists?(:listings, :list_id)
  end

  def down
    add_index :listings, :movie_id if !index_exists?(:listings, :movie_id)
    add_index :listings, :list_id if !index_exists?(:listings, :list_id)
  end
end
