require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
    options.add_argument("--no-sandbox")
    # Chrome's password manager / breach-detection prompt (fixtures use "password")
    # can swallow clicks in the next test.
    options.add_argument("--disable-features=PasswordLeakDetection,PasswordManagerOnboarding")
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)
    options.add_preference("profile.password_manager_leak_detection", false)
    options.add_option("goog:loggingPrefs", { browser: "ALL" })
  end

  # The first request after boot can be slow (asset/importmap warmup).
  Capybara.default_max_wait_time = 5

  # test_helper.rb already includes Capybara::Minitest::Assertions into
  # ActiveSupport::TestCase, so Rails' own include here is a no-op and
  # Capybara::DSL's uncounted assert_* methods win. Prepend restores them.
  prepend Capybara::Minitest::Assertions

  def sign_in_via_form(user, password: "password")
    visit new_session_path
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_on "Sign in"
  end

  # Importmap modules load asynchronously; wait until a Stimulus controller
  # has connected before interacting with it.
  def wait_for_stimulus_controller(identifier)
    page.document.synchronize do
      connected = page.evaluate_script(
        "!!window.Stimulus && window.Stimulus.controllers.some((c) => c.identifier === #{identifier.to_json})"
      )
      raise Capybara::ExpectationNotMet, "Stimulus controller #{identifier} not connected" unless connected
    end
  end

  # Console errors from the browser (CSP violations show up here).
  def browser_errors
    page.driver.browser.logs.get(:browser).select { |entry| entry.level == "SEVERE" }.map(&:message)
  end
end
