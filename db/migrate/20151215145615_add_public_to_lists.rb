class AddPublicToLists < ActiveRecord::Migration[5.1]
  def change
    add_column :lists, :is_public, :boolean, null: false, default: false
  end
end
