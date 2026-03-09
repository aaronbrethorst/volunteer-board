require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should redirect to sign in when not authenticated" do
    get edit_profile_path
    assert_redirected_to new_session_path
  end

  test "should get edit form when signed in" do
    sign_in_as(@user)
    get edit_profile_path
    assert_response :success
    assert_select "form"
    assert_select "input[name='user[name]']"
    assert_select "textarea[name='user[bio]']"
    assert_select "input[name='user[portfolio_url]']"
  end

  test "should not have fields for github or linkedin usernames" do
    sign_in_as(@user)
    get edit_profile_path
    assert_response :success
    assert_select "input[name='user[github_username]']", count: 0
    assert_select "input[name='user[linkedin_username]']", count: 0
  end

  test "should update profile with valid data" do
    sign_in_as(@user)
    patch profile_path, params: { user: { name: "Updated Name", bio: "New bio", portfolio_url: "https://mysite.com" } }
    assert_redirected_to user_path(@user)
    @user.reload
    assert_equal "Updated Name", @user.name
    assert_equal "New bio", @user.bio
    assert_equal "https://mysite.com", @user.portfolio_url
  end

  test "should not update profile with blank name" do
    sign_in_as(@user)
    patch profile_path, params: { user: { name: "", bio: "New bio" } }
    assert_response :unprocessable_entity
    @user.reload
    assert_not_equal "", @user.name
  end

  test "profile edit always edits current user not another user" do
    sign_in_as(@user)
    get edit_profile_path
    assert_response :success
    assert_select "input[value='#{@user.name}']"
  end

  test "should not allow mass assignment of site_admin via profile update" do
    sign_in_as(@user)
    assert_not @user.site_admin?
    patch profile_path, params: { user: { name: "Hacker", site_admin: true } }
    @user.reload
    assert_not @user.site_admin?
  end

  test "should not allow changing email_address via profile update" do
    sign_in_as(@user)
    original_email = @user.email_address
    patch profile_path, params: { user: { name: "Valid Name", email_address: "hacked@evil.com" } }
    @user.reload
    assert_equal original_email, @user.email_address
  end
end
