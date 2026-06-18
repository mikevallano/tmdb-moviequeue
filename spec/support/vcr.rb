VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
  config.ignore_localhost = true

  # Ignore api_key query parameter when matching requests to cassettes
  config.default_cassette_options = {
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:api_key)]
  }
end
