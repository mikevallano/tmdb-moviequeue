source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Devise for Authentication https://github.com/heartcombo/devise
gem 'devise'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use Redis for Action Cable https://github.com/redis/redis-rb
gem "redis"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem "solid_cache"
# gem "solid_queue"
# gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use ActiveHash to build ruby hashes as a readonly datasource for an ActiveRecord-like model. https://github.com/active-hash/active_hash
gem 'active_hash', '~> 3.3', '>= 3.3.1'

# Generates searchable, HTML-formatted documentation for Ruby code https://github.com/rails/sdoc
gem 'sdoc', '~> 2.6.1', group: :doc

# Simple, Heroku-friendly Rails app configuration using ENV and a single YAML file https://github.com/laserlemon/figaro
gem 'figaro'

# Create pretty URLs and work with human-friendly strings as if they were numeric ids https://github.com/norman/friendly_id
gem 'friendly_id'

# Makes sending HTTP requests and consuming RESTful web services simple and straightforward https://github.com/jnunemaker/httparty
gem 'httparty'

# Easy pagination html and css https://github.com/mislav/will_paginate
gem 'will_paginate'

# Middleware that displays speed badge for every HTML page, along with (optional) flamegraphs and memory profiling. https://github.com/MiniProfiler/rack-mini-profiler
gem 'rack-mini-profiler'

# Format dates and times based on human-friendly examples, not arcane strftime directives. https://github.com/jeremyw/stamp
gem 'stamp'

# The official modern SDK for integrating Sentry error monitoring and performance tracking into Rails applications https://docs.sentry.io/platforms/ruby/guides/rails/
gem 'sentry-ruby' # https://github.com/getsentry/sentry-ruby
gem 'sentry-rails'


group :development, :test do
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  # gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  # gem "rubocop-rails-omakase", require: false
  
  # Pry is a runtime developer console and IRB alternative with powerful introspection capabilities. https://github.com/pry/pry
  gem 'pry'

  # Generate random data for specs and seeds (an antequated fork of Faker) https://github.com/ffaker/ffaker
  gem 'ffaker'

  # Prints Ruby objects in full color exposing their internal structure with proper indentation https://github.com/awesome-print/awesome_print
  gem 'awesome_print'

  # Testing framework alternative to the default testing framework Minitest. https://github.com/rspec/rspec-rails
  gem 'rspec-rails', '~> 6.1.0'

  # Fixtures replacement that builds sample objects on the fly for testing https://github.com/thoughtbot/factory_bot_rails
  gem 'factory_bot_rails'

  # Generates table diagram run `bundle exec erd` https://github.com/voormedia/rails-erd
  gem 'rails-erd', require: false 

  # RSpec-specific analysis for your projects, as an extension to RuboCop. https://github.com/rubocop/rubocop-rspec
  gem 'rubocop-rspec'

  # Preview email in the default browser instead of sending it. https://github.com/ryanb/letter_opener
  gem 'letter_opener'

  # Extension for Capybara that lets you easily test ActionMailer and Mail messages in your acceptance tests. https://github.com/DavyJonesLocker/capybara-email
  gem 'capybara-email'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Replaces the standard Rails error page with a much better and more useful error page https://github.com/BetterErrors/better_errors
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]

  # Capybara helps you test web applications by simulating how a real user would interact with your app https://github.com/teamcapybara/capybara
  gem "capybara"

  # WebDriver for automating web browsers in system tests, used by Capybara for browser automation https://github.com/SeleniumHQ/selenium/tree/trunk/rb
  gem "selenium-webdriver"

  # Brings back controller test helpers (assigns, assert_template) that were extracted from Rails 5+ https://github.com/rails/rails-controller-testing
  gem 'rails-controller-testing'

  # RSpec and Minitest matchers for testing common Rails functionality with simple one-liners https://github.com/thoughtbot/shoulda-matchers
  gem 'shoulda-matchers'

  # Strategies for cleaning databases between tests to ensure a clean state https://github.com/DatabaseCleaner/database_cleaner
  gem 'database_cleaner'

  # Opens files and URLs in the browser, commonly used with Capybara's save_and_open_page for debugging tests https://github.com/copiousfreetime/launchy
  gem 'launchy'

  # Records HTTP interactions and replays them during test runs to speed up tests and avoid hitting external APIs https://github.com/vcr/vcr
  gem 'vcr'

  # Stubs and sets expectations on HTTP requests, works with VCR to prevent real HTTP connections during tests https://github.com/bblimke/webmock
  gem 'webmock'
end
