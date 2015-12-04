class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.integer :owner_id
      t.string :name

      t.timestamps null: false
    end
  end
end
