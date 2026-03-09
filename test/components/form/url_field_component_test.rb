require "test_helper"

class Form::UrlFieldComponentTest < ViewComponent::TestCase
  test "renders label and url input with correct classes" do
    render_inline(Form::UrlFieldComponent.new(form: form_for(Organization.new), attribute: :website_url))

    assert_selector "div label.form-label", text: "Website url"
    assert_selector "div input.form-control[type=url][name='organization[website_url]']"
  end

  test "renders custom label text" do
    render_inline(Form::UrlFieldComponent.new(form: form_for(Organization.new), attribute: :website_url, label: "Website URL"))

    assert_selector "label.form-label", text: "Website URL"
  end

  test "passes through additional options" do
    render_inline(Form::UrlFieldComponent.new(form: form_for(Organization.new), attribute: :website_url, placeholder: "https://example.com"))

    assert_selector "input[placeholder='https://example.com']"
  end

  private

  def form_for(model)
    ActionView::Helpers::FormBuilder.new(model.model_name.param_key, model, vc_test_controller.view_context, {})
  end
end
