class OrganizationLogoComponent < ViewComponent::Base
  SIZES = {
    xs: { container: "w-5 h-5 rounded", text: "text-xs", font: "font-bold" },
    sm: { container: "w-10 h-10 rounded-full", text: "text-sm", font: "font-semibold" },
    md: { container: "w-12 h-12 rounded-lg", text: "text-lg", font: "font-bold" },
    lg: { container: "w-14 h-14 rounded-xl", text: "text-xl", font: "font-bold" },
    xl: { container: "w-20 h-20 sm:w-24 sm:h-24 rounded-xl", text: "text-3xl sm:text-4xl", font: "font-bold" }
  }.freeze

  VARIANTS = {
    light: {
      image: "ring-1 ring-gray-200",
      fallback_bg: "bg-amber-50 ring-1 ring-amber-200",
      fallback_text: "text-amber-600"
    },
    dark: {
      image: "ring-2 ring-white/20 shadow-lg",
      fallback_bg: "bg-amber-500/20 ring-2 ring-amber-400/30 shadow-lg",
      fallback_text: "text-amber-400"
    }
  }.freeze

  def initialize(organization:, size: :md, variant: :light, extra_classes: "")
    @organization = organization
    @size = SIZES.fetch(size)
    @variant = VARIANTS.fetch(variant)
    @extra_classes = extra_classes
  end

  def image_classes
    "#{@size[:container]} object-cover #{@variant[:image]} #{@extra_classes}".squish
  end

  def fallback_classes
    "#{@size[:container]} inline-flex items-center justify-center #{@variant[:fallback_bg]} #{@extra_classes}".squish
  end

  def initial_classes
    "#{@size[:text]} #{@size[:font]} #{@variant[:fallback_text]}"
  end

  def logo_attached?
    @organization.logo.attached?
  end

  def initial
    @organization.name.first.upcase
  end

  def alt_text
    "#{@organization.name} logo"
  end
end
