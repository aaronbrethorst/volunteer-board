require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated users" do
    get admin_users_path
    assert_redirected_to new_session_path
  end

  test "redirects non-admin users" do
    sign_in_as(users(:two))
    get admin_users_path
    assert_redirected_to root_path
    assert_equal "Not authorized", flash[:alert]
  end

  test "admin can view users list" do
    sign_in_as(users(:one))
    get admin_users_path
    assert_response :success
  end

  test "shows user names and emails" do
    sign_in_as(users(:one))
    get admin_users_path
    assert_select "td", text: users(:one).name
    assert_select "td", text: users(:one).email_address
    assert_select "td", text: users(:two).name
    assert_select "td", text: users(:two).email_address
  end

  test "index paginates users" do
    sign_in_as(users(:one))

    25.times do |i|
      User.create!(name: "Paginated User #{i}", email_address: "paginated#{i}@example.com", password: "password")
    end

    get admin_users_path
    assert_response :success
    assert_select "nav[aria-label]"
  end
end
