require "test_helper"

class SentryConfigTest < ActiveSupport::TestCase
  test "cookies are never sent to Sentry" do
    env = Rack::MockRequest.env_for(
      "https://ossvolunteers.com/listings",
      "HTTP_COOKIE" => "session_id=signed-session-value; theme=dark"
    )

    request = Sentry::RequestInterface.new(
      env: env,
      data_collection: Sentry.configuration.data_collection,
      rack_env_whitelist: Sentry.configuration.rack_env_whitelist
    )

    assert_empty request.cookies.to_h
    assert_no_match "signed-session-value", request.to_h.to_s
  end

  test "deprecated send_default_pii is not enabled" do
    assert_not Sentry.configuration.send_default_pii
  end
end
