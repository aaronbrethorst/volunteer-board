require "test_helper"

class Form::TextFieldComponentTest < ViewComponent::TestCase
  test "renders label and text input with correct classes" do
    render_inline(Form::TextFieldComponent.new(form: form_for(Organization.new), attribute: :name))

    assert_selector "div label.form-label", text: "Name"
    assert_selector "div input.form-control[type=text][name='organization[name]']"
  end

  test "renders custom label text" do
    render_inline(Form::TextFieldComponent.new(form: form_for(Organization.new), attribute: :name, label: "Org Name"))

    assert_selector "label.form-label", text: "Org Name"
  end

  test "passes through additional options" do
    render_inline(Form::TextFieldComponent.new(form: form_for(Organization.new), attribute: :name, placeholder: "Enter name"))

    assert_selector "input[placeholder='Enter name']"
  end

  private

  def form_for(model)
    ActionView::Helpers::FormBuilder.new(model.model_name.param_key, model, vc_test_controller.view_context, {})
  end
end
