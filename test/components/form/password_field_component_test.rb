require "test_helper"

class Form::PasswordFieldComponentTest < ViewComponent::TestCase
  test "renders label and password input with correct classes" do
    render_inline(Form::PasswordFieldComponent.new(form: form_for(User.new), attribute: :password))

    assert_selector "div label.form-label", text: "Password"
    assert_selector "div input.form-control[type=password][name='user[password]']"
  end

  test "renders custom label text" do
    render_inline(Form::PasswordFieldComponent.new(form: form_for(User.new), attribute: :password, label: "New Password"))

    assert_selector "label.form-label", text: "New Password"
  end

  test "passes through additional options" do
    render_inline(Form::PasswordFieldComponent.new(form: form_for(User.new), attribute: :password, minlength: 8))

    assert_selector "input[minlength='8']"
  end

  private

  def form_for(model)
    ActionView::Helpers::FormBuilder.new(model.model_name.param_key, model, vc_test_controller.view_context, {})
  end
end
