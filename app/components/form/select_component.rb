class Form::SelectComponent < ViewComponent::Base
  def initialize(form:, attribute:, choices:, label: nil, prompt: nil, **options)
    @form = form
    @attribute = attribute
    @choices = choices
    @label = label
    @prompt = prompt
    @options = options
  end
end
