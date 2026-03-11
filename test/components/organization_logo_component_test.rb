require "test_helper"

class OrganizationLogoComponentTest < ViewComponent::TestCase
  setup do
    @organization = organizations(:one)
  end

  test "renders fallback initial when no logo attached" do
    render_inline(OrganizationLogoComponent.new(organization: @organization))

    assert_selector "span", text: @organization.name.first.upcase
  end

  test "renders fallback with light variant by default" do
    render_inline(OrganizationLogoComponent.new(organization: @organization))

    assert_selector "div.bg-amber-50"
    assert_selector "span.text-amber-600"
  end

  test "renders fallback with dark variant" do
    render_inline(OrganizationLogoComponent.new(organization: @organization, variant: :dark))

    assert_selector "span.text-amber-400"
  end

  test "renders md size by default" do
    render_inline(OrganizationLogoComponent.new(organization: @organization))

    assert_selector "div.w-12.h-12.rounded-lg"
  end

  test "renders xs size" do
    render_inline(OrganizationLogoComponent.new(organization: @organization, size: :xs))

    assert_selector "div.w-5.h-5.rounded"
  end

  test "renders sm size" do
    render_inline(OrganizationLogoComponent.new(organization: @organization, size: :sm))

    assert_selector "div.w-10.h-10.rounded-full"
  end

  test "renders lg size" do
    render_inline(OrganizationLogoComponent.new(organization: @organization, size: :lg))

    assert_selector "div.w-14.h-14.rounded-xl"
  end

  test "renders xl size" do
    render_inline(OrganizationLogoComponent.new(organization: @organization, size: :xl))

    assert_selector "div.w-20.h-20.rounded-xl"
  end

  test "applies extra classes" do
    render_inline(OrganizationLogoComponent.new(organization: @organization, extra_classes: "shadow-sm"))

    assert_selector "div.shadow-sm"
  end
end
