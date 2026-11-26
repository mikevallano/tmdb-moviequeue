# frozen_string_literal: true

# Capybara 3.40 resets Chrome between tests with
# Storage.clearDataForOrigin(origin: '*'). Chrome 158+ rejects '*' as an
# invalid URL, which fails every JS spec during teardown. When that happens,
# clear cookies for all origins (that's what signs users out) and storage for
# the app server's origin instead. Remove once Capybara ships a fix.
require 'capybara/selenium/driver'
require 'capybara/selenium/driver_specializations/chrome_driver'

module ChromeResetFix
  private

  def execute_cdp(cmd, params = {})
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError
    raise unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
    origin = Capybara.current_session.server&.base_url
    super(cmd, params.merge(origin: origin)) if origin
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetFix)
