class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :list, index: true, foreign_key: true
      t.integer :member_id

      t.timestamps null: false
    end
  end
end
