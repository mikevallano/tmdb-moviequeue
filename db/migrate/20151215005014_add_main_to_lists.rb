class AddMainToLists < ActiveRecord::Migration
  def change
    add_column :lists, :main, :boolean
  end
end
