source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'rails', '~> 8.1.4', '>= 8.1.4.1'


gem 'active_hash', '~> 3.3', '>= 3.3.1'
gem 'puma', '7.2.1'
gem 'pg', '~> 1.1'

gem 'hotwire-rails'
gem 'importmap-rails'
gem 'sdoc', '~> 2.6.1', group: :doc
gem 'devise', '~> 5.0.3'
gem 'figaro'
gem 'friendly_id'
gem 'httparty'
gem 'anthropic'
gem 'rails_12factor', group: :production
gem 'will_paginate'
gem 'rack-mini-profiler'
gem 'stamp'
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'propshaft'
gem 'stimulus-rails'
gem 'turbo-rails'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'


# Ruby 3.4+ compatibility - stdlib gems that were extracted
gem 'observer'
gem 'ostruct'
gem 'base64'
gem 'bigdecimal'
gem 'mutex_m'
gem 'drb'
gem 'json', '~> 2.7' # Pin to 2.x - json 3.0 removed quirks_mode breaking Rails compatibility

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'pry'
  gem 'ffaker'
  gem 'awesome_print'
  gem 'rspec-rails', '~> 6.1.0'
  gem 'factory_bot_rails'
  gem 'rails-erd', require: false # generates table diagram run `bundle exec erd`
  gem 'brakeman', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'letter_opener'
  gem 'capybara-email'
end

group :test do
    gem 'rails-controller-testing'
    gem 'shoulda-matchers'
    gem 'capybara', '~> 3.40' # Ruby 3.4 compatibility (fixes Rack::Handler errors)
    gem 'database_cleaner'
    gem 'launchy'
    gem 'selenium-webdriver' # manages chromedriver itself (Selenium Manager)
    gem 'vcr'
    gem 'webmock'
end

# Use Redis for Action Cable
gem "redis", "~> 4.0"
