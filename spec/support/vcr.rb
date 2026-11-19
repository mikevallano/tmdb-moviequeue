VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
  config.ignore_localhost = true

  # Keep the real TMDB key out of recorded cassettes.
  config.filter_sensitive_data("<TMDB_API_KEY>") { ENV["tmdb_api_key"] }

  # Match on the URI minus the api_key param, so cassettes replay no matter
  # which key (if any) is configured, e.g. on Dependabot CI runs.
  config.register_request_matcher :uri_without_api_key do |request_1, request_2|
    strip_key = ->(uri) { uri.sub(/([?&])api_key=[^&]*&?/, '\1').chomp("&").chomp("?") }
    strip_key.call(request_1.uri) == strip_key.call(request_2.uri)
  end
  config.default_cassette_options = { match_requests_on: [:method, :uri_without_api_key] }
end
