class RenameMainToMainListOnLists < ActiveRecord::Migration[5.1]
  def change
    rename_column :lists, :main, :main_list
  end
end
