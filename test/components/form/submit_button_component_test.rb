require "test_helper"

class Form::SubmitButtonComponentTest < ViewComponent::TestCase
  test "renders primary variant by default" do
    render_inline(Form::SubmitButtonComponent.new(form: form_for(Organization.new)))

    assert_selector "input[type=submit][class*='bg-indigo-600']"
  end

  test "renders success variant" do
    render_inline(Form::SubmitButtonComponent.new(form: form_for(Organization.new), variant: :success))

    assert_selector "input[type=submit][class*='bg-green-600']"
  end

  test "renders custom label" do
    render_inline(Form::SubmitButtonComponent.new(form: form_for(Organization.new), label: "Save Changes"))

    assert_selector "input[type=submit][value='Save Changes']"
  end

  private

  def form_for(model)
    ActionView::Helpers::FormBuilder.new(model.model_name.param_key, model, vc_test_controller.view_context, {})
  end
end
