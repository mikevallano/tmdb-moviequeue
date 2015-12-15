class AddPublicToLists < ActiveRecord::Migration
  def change
    add_column :lists, :is_public, :boolean, null: false, default: false
  end
end
