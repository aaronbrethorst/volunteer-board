class Form::TextFieldComponent < ViewComponent::Base
  def initialize(form:, attribute:, label: nil, **options)
    @form = form
    @attribute = attribute
    @label = label
    @options = options
  end
end
