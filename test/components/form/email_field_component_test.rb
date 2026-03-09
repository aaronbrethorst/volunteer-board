require "test_helper"

class Form::EmailFieldComponentTest < ViewComponent::TestCase
  test "renders label and email input with correct classes" do
    render_inline(Form::EmailFieldComponent.new(form: form_for(User.new), attribute: :email_address))

    assert_selector "div label.form-label", text: "Email address"
    assert_selector "div input.form-control[type=email][name='user[email_address]']"
  end

  test "renders custom label text" do
    render_inline(Form::EmailFieldComponent.new(form: form_for(User.new), attribute: :email_address, label: "Email"))

    assert_selector "label.form-label", text: "Email"
  end

  test "passes through additional options" do
    render_inline(Form::EmailFieldComponent.new(form: form_for(User.new), attribute: :email_address, placeholder: "you@example.com"))

    assert_selector "input[placeholder='you@example.com']"
  end

  private

  def form_for(model)
    ActionView::Helpers::FormBuilder.new(model.model_name.param_key, model, vc_test_controller.view_context, {})
  end
end
