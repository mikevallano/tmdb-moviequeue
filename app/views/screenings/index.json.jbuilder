json.array!(@screenings) do |screening|
  json.extract! screening, :id, :user_id, :movie_id, :date_watched, :location_watched, :notes
  json.url screening_url(screening, format: :json)
end
