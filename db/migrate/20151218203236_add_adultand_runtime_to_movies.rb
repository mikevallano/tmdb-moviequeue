class AddAdultandRuntimeToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :adult, :boolean, null: false, default: false
    add_column :movies, :runtime, :integer
  end
end
