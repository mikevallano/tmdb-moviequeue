class AddUniqueIndexToListings < ActiveRecord::Migration[7.1]
  def up
    return if index_exists?(:listings, [:movie_id, :list_id])
    add_index :listings, [:movie_id, :list_id], unique: true
  end

  def down
    return unless index_exists?(:listings, [:movie_id, :list_id])
    remove_index :listings, [:movie_id, :list_id]
  end
end
