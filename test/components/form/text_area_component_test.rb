require "test_helper"

class Form::TextAreaComponentTest < ViewComponent::TestCase
  test "renders label and textarea with correct classes" do
    render_inline(Form::TextAreaComponent.new(form: form_for(Organization.new), attribute: :description))

    assert_selector "div label.form-label", text: "Description"
    assert_selector "div textarea.form-control[name='organization[description]']"
  end

  test "renders custom label text" do
    render_inline(Form::TextAreaComponent.new(form: form_for(Organization.new), attribute: :description, label: "Details"))

    assert_selector "label.form-label", text: "Details"
  end

  test "passes through additional options" do
    render_inline(Form::TextAreaComponent.new(form: form_for(Organization.new), attribute: :description, rows: 5))

    assert_selector "textarea[rows='5']"
  end

  private

  def form_for(model)
    ActionView::Helpers::FormBuilder.new(model.model_name.param_key, model, vc_test_controller.view_context, {})
  end
end
