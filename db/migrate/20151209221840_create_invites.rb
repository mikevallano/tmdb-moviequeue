class CreateInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :invites do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.string :token
      t.string :email
      t.integer :list_id

      t.timestamps null: false
    end
  end
end
