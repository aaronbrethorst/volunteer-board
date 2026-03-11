class Form::FileFieldComponent < ViewComponent::Base
  FILE_FIELD_CLASSES = "block w-full text-sm text-slate-800 file:mr-4 file:py-2 file:px-4 " \
    "file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-slate-800 " \
    "file:text-white hover:file:bg-slate-700"

  def initialize(form:, attribute:, label: nil, **options)
    @form = form
    @attribute = attribute
    @label = label
    @options = options
  end
end
