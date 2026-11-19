# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'


# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
require 'devise'
require 'shoulda/matchers'
require 'support/controller_helpers'
require 'support/feature_helpers'
require 'support/mailer_helpers'
require 'support/vcr'
require 'capybara/email/rspec'
require 'support/wait_for_ajax'

ActiveRecord::Migration.maintain_test_schema!

Capybara.default_max_wait_time = 4

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Chrome's password manager can pop up a "save password" or "change your
# password" (leaked password) dialog after a test signs in. That dialog
# swallows keyboard input for the rest of the test, so typing in a field
# silently does nothing. Turn those features off.
def chrome_options_for_tests(headless:)
  Selenium::WebDriver::Chrome::Options.new.tap do |options|
    options.add_argument('--headless=new') if headless
    options.add_argument('--disable-features=PasswordLeakDetection')
    options.add_preference('credentials_enable_service', false)
    options.add_preference('profile.password_manager_enabled', false)
    options.add_preference('profile.password_manager_leak_detection', false)
  end
end

Capybara.register_driver :chrome_headless_no_passwords do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options_for_tests(headless: true))
end

Capybara.register_driver :chrome_no_passwords do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options_for_tests(headless: false))
end

# To actually see the tests in the browser locally,
# use :chrome_no_passwords instead of :chrome_headless_no_passwords
# Capybara.javascript_driver = :chrome_no_passwords
Capybara.javascript_driver = :chrome_headless_no_passwords

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.include ControllerHelpers, type: :controller
  config.include FeatureHelpers, type: :feature
  config.include MailerHelpers
  config.include WaitForAjax, type: :feature
  config.before(:each) { reset_mailer }
  config.include FactoryBot::Syntax::Methods

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    # set the default
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
end
