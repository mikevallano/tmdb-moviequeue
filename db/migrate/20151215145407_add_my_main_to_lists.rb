class AddMyMainToLists < ActiveRecord::Migration[5.1]
  def change
    add_column :lists, :my_main, :boolean, null: false, default: false
  end
end
