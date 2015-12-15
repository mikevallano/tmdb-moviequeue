class RenameMainToMainListOnLists < ActiveRecord::Migration
  def change
    rename_column :lists, :main, :main_list
  end
end
