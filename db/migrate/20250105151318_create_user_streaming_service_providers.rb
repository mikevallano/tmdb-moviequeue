class CreateUserStreamingServiceProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :user_streaming_service_providers do |t|
      t.references :user, null: false, foreign_key: true
      t.uuid :streaming_service_provider_id, null: false

      t.timestamps
    end
  end
end
