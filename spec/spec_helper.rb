require 'devise'
require 'support/controller_helpers'
require 'support/feature_helpers'

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
  config.include FeatureHelpers, type: :feature
  Warden.test_mode!

  config.after do
    Warden.test_reset!
  end
end
