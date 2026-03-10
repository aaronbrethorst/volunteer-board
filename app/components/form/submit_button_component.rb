class Form::SubmitButtonComponent < ViewComponent::Base
  VARIANT_CLASSES = {
    primary: "bg-slate-700 hover:brightness-[1.4] text-white px-4 py-2 rounded-md transition cursor-pointer",
    success: "bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-md transition text-sm font-medium cursor-pointer",
    danger: "bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md transition text-sm font-medium cursor-pointer"
  }.freeze

  def initialize(form:, label: nil, variant: :primary, **options)
    @form = form
    @label = label
    @variant = variant
    @options = options
  end

  def css_classes
    VARIANT_CLASSES.fetch(@variant)
  end
end
