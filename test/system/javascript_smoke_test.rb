require "application_system_test_case"

# Guards the CSP + importmap + Stimulus + Trix stack: if the CSP blocks the
# importmap script, none of these behaviors work but controller tests still pass.
class JavascriptSmokeTest < ApplicationSystemTestCase
  test "user dropdown opens via Stimulus after sign in" do
    sign_in_via_form users(:two)
    assert_text "Welcome back!"

    assert_no_selector "a", text: "Edit Profile", visible: true
    wait_for_stimulus_controller "dropdown"
    click_on users(:two).name
    assert_selector "a", text: "Edit Profile", visible: true
  end

  test "Trix editor loads on listing form" do
    sign_in_via_form users(:one)
    assert_text "Welcome back!"
    visit edit_listing_path(listings(:open_listing))

    assert_selector "trix-editor"
    assert_selector "trix-toolbar"
  end

  test "pages load without CSP violations" do
    visit root_path
    assert_selector "body"
    sign_in_via_form users(:one)
    assert_text "Welcome back!"
    visit edit_listing_path(listings(:open_listing))
    assert_selector "trix-editor"

    # The Umami analytics script is currently blocked by script-src; whether to
    # allow it is a separate policy decision, so it's excluded here.
    csp_errors = browser_errors.grep(/Content Security Policy/i).grep_v(/cloud\.umami\.is/)
    assert_empty csp_errors
  end
end
