source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'rails', '~> 7.1.3'
gem 'active_hash', '~> 3.3', '>= 3.3.1'
gem 'puma', '6.4.2'
gem 'pg', '~> 1.1'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'

gem 'hotwire-rails'
gem 'importmap-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 2.6.1', group: :doc
gem 'devise', '~> 4.9.3'
gem 'figaro'
gem 'friendly_id'
gem 'httparty'
gem 'rails_12factor', group: :production
gem 'will_paginate'
gem 'rack-mini-profiler'
gem 'stamp'
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

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
  gem 'rubocop-rspec'
  gem 'letter_opener'
  gem 'capybara-email'
end

group :test do
    gem 'rails-controller-testing'
    gem 'shoulda-matchers'
    gem 'capybara'
    gem 'database_cleaner'
    gem 'launchy'
    gem 'webdrivers'
    gem 'vcr'
    gem 'webmock'
end

# Use Redis for Action Cable
gem "redis", "~> 4.0"
