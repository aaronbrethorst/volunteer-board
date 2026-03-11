require "test_helper"

class Form::FileFieldComponentTest < ViewComponent::TestCase
  test "renders file input with custom styling" do
    render_inline(Form::FileFieldComponent.new(form: form_for(Organization.new), attribute: :logo))

    assert_selector "div input[type=file][name='organization[logo]']"
    assert_selector "input[class*='file:bg-slate-800']"
  end

  test "renders label" do
    render_inline(Form::FileFieldComponent.new(form: form_for(Organization.new), attribute: :logo))

    assert_selector "div label.form-label", text: "Logo"
  end

  test "renders custom label text" do
    render_inline(Form::FileFieldComponent.new(form: form_for(Organization.new), attribute: :logo, label: "Upload Logo"))

    assert_selector "label.form-label", text: "Upload Logo"
  end

  test "passes through additional options" do
    render_inline(Form::FileFieldComponent.new(form: form_for(Organization.new), attribute: :logo, accept: "image/*"))

    assert_selector "input[accept='image/*']"
  end

  private

  def form_for(model)
    ActionView::Helpers::FormBuilder.new(model.model_name.param_key, model, vc_test_controller.view_context, {})
  end
end
