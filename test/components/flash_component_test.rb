require "test_helper"

class FlashComponentTest < ViewComponent::TestCase
  test "renders nothing when flash is empty" do
    render_inline(FlashComponent.new(flash: {}))

    assert_no_selector "div"
  end

  test "renders notice flash with blue styling" do
    render_inline(FlashComponent.new(flash: { "notice" => "Record saved." }))

    assert_text "Record saved."
    assert_selector "div.bg-blue-50.border-blue-400.text-blue-800"
  end

  test "renders success flash with green styling" do
    render_inline(FlashComponent.new(flash: { "success" => "Well done!" }))

    assert_text "Well done!"
    assert_selector "div.bg-green-50.border-green-400.text-green-800"
  end

  test "renders alert flash with red styling" do
    render_inline(FlashComponent.new(flash: { "alert" => "Something went wrong." }))

    assert_text "Something went wrong."
    assert_selector "div.bg-red-50.border-red-400.text-red-800"
  end

  test "renders error flash with red styling" do
    render_inline(FlashComponent.new(flash: { "error" => "Failed to save." }))

    assert_text "Failed to save."
    assert_selector "div.bg-red-50.border-red-400.text-red-800"
  end

  test "renders unknown flash type with gray styling" do
    render_inline(FlashComponent.new(flash: { "info" => "FYI." }))

    assert_text "FYI."
    assert_selector "div.bg-gray-50.border-gray-400.text-gray-800"
  end

  test "renders multiple flash messages" do
    render_inline(FlashComponent.new(flash: { "notice" => "Saved.", "alert" => "Check input." }))

    assert_text "Saved."
    assert_text "Check input."
    assert_selector "div.bg-blue-50", count: 1
    assert_selector "div.bg-red-50", count: 1
  end

  test "renders dismiss button with flash stimulus controller" do
    render_inline(FlashComponent.new(flash: { "notice" => "Hello" }))

    assert_selector "[data-controller='flash']"
    assert_selector "button[data-action='click->flash#dismiss']"
    assert_selector "button[aria-label='Dismiss']"
  end
end
