class RenameMyMainToIsMainOnLists < ActiveRecord::Migration
  def change
    rename_column :lists, :my_main, :is_main
  end
end
