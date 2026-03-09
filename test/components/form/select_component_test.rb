require "test_helper"

class Form::SelectComponentTest < ViewComponent::TestCase
  test "renders select with choices" do
    choices = [ [ "Option A", "a" ], [ "Option B", "b" ] ]
    render_inline(Form::SelectComponent.new(form: form_for(Organization.new), attribute: :name, choices: choices))

    assert_selector "div label.form-label", text: "Name"
    assert_selector "div select.form-control[name='organization[name]']"
    assert_selector "option[value='a']", text: "Option A"
    assert_selector "option[value='b']", text: "Option B"
  end

  test "renders prompt as blank option" do
    choices = [ [ "Option A", "a" ] ]
    render_inline(Form::SelectComponent.new(form: form_for(Organization.new), attribute: :name, choices: choices, prompt: "Pick one"))

    assert_selector "option[value='']", text: "Pick one"
  end

  test "renders custom label text" do
    choices = [ [ "Option A", "a" ] ]
    render_inline(Form::SelectComponent.new(form: form_for(Organization.new), attribute: :name, choices: choices, label: "Choose"))

    assert_selector "label.form-label", text: "Choose"
  end

  private

  def form_for(model)
    ActionView::Helpers::FormBuilder.new(model.model_name.param_key, model, vc_test_controller.view_context, {})
  end
end
