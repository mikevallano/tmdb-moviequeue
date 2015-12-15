class RemoveMainListFromLists < ActiveRecord::Migration
  def change
    remove_column :lists, :main_list
  end
end
