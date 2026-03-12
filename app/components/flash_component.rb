class FlashComponent < ViewComponent::Base
  def initialize(flash:)
    @flash = flash
  end

  def render?
    @flash.any?
  end

  private

  def css_class_for(type)
    case type.to_s
    when "notice"
      "bg-blue-50 border-blue-400 text-blue-800"
    when "success"
      "bg-green-50 border-green-400 text-green-800"
    when "alert", "error"
      "bg-red-50 border-red-400 text-red-800"
    else
      "bg-gray-50 border-gray-400 text-gray-800"
    end
  end
end
