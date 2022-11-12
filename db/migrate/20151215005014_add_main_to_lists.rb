class AddMainToLists < ActiveRecord::Migration[5.1]
  def change
    add_column :lists, :main, :boolean
  end
end
