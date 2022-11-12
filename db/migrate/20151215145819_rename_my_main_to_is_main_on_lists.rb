class RenameMyMainToIsMainOnLists < ActiveRecord::Migration[5.1]
  def change
    rename_column :lists, :my_main, :is_main
  end
end
