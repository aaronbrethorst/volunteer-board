require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
  end

  test "should show public profile for any user" do
    get user_path(@user)
    assert_response :success
    assert_select "h1", @user.name
  end

  test "should show public profile when not signed in" do
    get user_path(@user)
    assert_response :success
  end

  test "should display bio on public profile" do
    get user_path(@user)
    assert_response :success
    assert_select "p", /#{@user.bio}/ if @user.bio.present?
  end

  test "should display github link when user has github_username" do
    @user.update!(github_username: "octocat")
    get user_path(@user)
    assert_response :success
    assert_select "a[href='https://github.com/octocat']"
  end

  test "should display linkedin link when user has linkedin_username" do
    @user.update!(linkedin_username: "johndoe")
    get user_path(@user)
    assert_response :success
    assert_select "a[href='https://linkedin.com/in/johndoe']"
  end

  test "should display portfolio url when present" do
    @user.update!(portfolio_url: "https://example.com")
    get user_path(@user)
    assert_response :success
    assert_select "a[href='https://example.com']"
  end
end
