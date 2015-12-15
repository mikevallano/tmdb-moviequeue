class AddMyMainToLists < ActiveRecord::Migration
  def change
    add_column :lists, :my_main, :boolean, null: false, default: false
  end
end
