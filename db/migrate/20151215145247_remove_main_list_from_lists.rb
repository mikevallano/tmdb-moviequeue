class RemoveMainListFromLists < ActiveRecord::Migration[5.1]
  def change
    remove_column :lists, :main_list
  end
end
