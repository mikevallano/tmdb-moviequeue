class AddDefaultLocationToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :default_location, :string
  end
end
