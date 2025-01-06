class UserStreamingServiceProvider < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to_active_hash :streaming_service_provider

  validates :user_id, uniqueness: {scope: :streaming_service_provider_id}
end
