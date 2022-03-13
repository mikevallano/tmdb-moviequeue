# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'


# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
require 'coveralls'
Coveralls.wear!('rails')
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

# Potential fix for CI problems
# capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
#   chromeOptions: {
#     args: %w[
#       headless disable-gpu no-sandbox
#       --window-size=1980,1080 --enable-features=NetworkService,NetworkServiceInProcess
#     ]
#   }
# )

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: chrome)
  # Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

# use selenium_chrome to actually see what's doing
Capybara.javascript_driver = :selenium_chrome_headless

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
