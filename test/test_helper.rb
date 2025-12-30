ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"
require "capybara/minitest"

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Disable parallel tests due to minitest 6 compatibility
  parallelize(workers: 1)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  # For Capybara system tests
  def login_as(user)
    magic_link = user.magic_links.create!(
      token: SecureRandom.urlsafe_base64(32),
      expires_at: 1.hour.from_now
    )
    visit auth_callback_path(token: magic_link.token)
  end

  # For integration tests without Capybara
  def login_user(user)
    magic_link = user.magic_links.create!(
      token: SecureRandom.urlsafe_base64(32),
      expires_at: 1.hour.from_now
    )
    get auth_callback_path(token: magic_link.token)
  end
end

# Configure Capybara
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_headless
