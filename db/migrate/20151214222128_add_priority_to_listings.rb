class AddPriorityToListings < ActiveRecord::Migration
  def change
    add_column :listings, :priority, :integer
  end
end
