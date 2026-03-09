ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "view_component/test_helpers"
require "view_component/system_test_helpers"
require_relative "test_helpers/session_test_helper"
require_relative "test_helpers/query_counter_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include ViewComponent::TestHelpers
    include Capybara::Minitest::Assertions

    # Add more helper methods to be used by all tests here...
  end
end
