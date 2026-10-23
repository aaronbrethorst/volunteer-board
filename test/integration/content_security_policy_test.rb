require "test_helper"

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "script-src carries a non-empty nonce that matches the page" do
    get root_path

    nonce = script_nonce
    assert nonce.present?, "expected a non-empty CSP nonce"
    assert_select "meta[name=csp-nonce][content=?]", nonce
    assert_select "script[type=importmap][nonce=?]", nonce
  end

  test "nonce differs on every request, even within one session" do
    sign_in_as users(:two)
    get root_path
    first = script_nonce
    get root_path
    assert_not_equal first, script_nonce
  end

  private

  def script_nonce
    response.headers["Content-Security-Policy"][/script-src[^;]*'nonce-([^']*)'/, 1]
  end
end
