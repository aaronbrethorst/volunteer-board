require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new registration form" do
    get new_registration_url
    assert_response :success
    assert_select "form"
  end

  test "should create user with valid data and send confirmation email" do
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
    assert_not user.email_confirmed?
    assert_enqueued_email_with EmailConfirmationMailer, :confirm, args: [ user ]
    assert_redirected_to root_url
    follow_redirect!
    assert_equal "Welcome to OSSVolunteers! Check your email for a confirmation link.", flash[:notice]
  end

  test "registration succeeds even if confirmation email enqueue fails" do
    # Override the mailer class method to simulate queue failure
    EmailConfirmationMailer.define_singleton_method(:confirm) { |_user| raise StandardError, "queue down" }

    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: {
          email_address: "queue-fail@example.com",
          password: "securepassword",
          password_confirmation: "securepassword",
          name: "Queue Fail User"
        }
      }
    end

    assert_redirected_to root_url
  ensure
    EmailConfirmationMailer.singleton_class.remove_method(:confirm)
  end

  test "should not send confirmation email on failed registration" do
    assert_no_emails do
      post registration_url, params: {
        user: {
          email_address: "",
          password: "securepassword",
          password_confirmation: "securepassword",
          name: "Bad User"
        }
      }
    end

    assert_response :unprocessable_entity
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
