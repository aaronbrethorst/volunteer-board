require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new registration form" do
    get new_registration_url
    assert_response :success
    assert_select "form"
  end

  test "should create user with valid data" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: {
          email_address: "newuser@example.com",
          password: "securepassword",
          password_confirmation: "securepassword",
          name: "New User"
        }
      }
    end

    user = User.find_by(email_address: "newuser@example.com")
    assert_not_nil user
    assert_equal "New User", user.name
    assert_redirected_to root_url
    follow_redirect!
    assert_equal "Welcome to VolunteerBoard!", flash[:notice]
  end

  test "should not create user with duplicate email" do
    existing = users(:one)

    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: existing.email_address,
          password: "securepassword",
          password_confirmation: "securepassword",
          name: "Duplicate User"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with missing name" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: "noname@example.com",
          password: "securepassword",
          password_confirmation: "securepassword",
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with missing email" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: "",
          password: "securepassword",
          password_confirmation: "securepassword",
          name: "No Email"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with mismatched passwords" do
    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: "mismatch@example.com",
          password: "securepassword",
          password_confirmation: "differentpassword",
          name: "Mismatch User"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
