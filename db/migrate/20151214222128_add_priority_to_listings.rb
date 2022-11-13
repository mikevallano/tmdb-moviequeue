class AddPriorityToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :priority, :integer
  end
end
