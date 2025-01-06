FactoryBot.define do
  factory :streaming_service_provider do
    id { SecureRandom.uuid }
    sequence(:display_name) { |n| "Provider #{n}" }
    sequence(:tmdb_provider_name) { |n| "Provider #{n}" }
    sequence(:tmdb_provider_id) { |n| n }
    tmdb_logo_path { "/9ghgSC0MA082EL6HLCW3GalykFD.jpg" }
    search_url {'/'}
  end

end
