require "test_helper"

class HomepageControllerTest < ActionDispatch::IntegrationTest
  setup do
    @open_listing = listings(:open_listing)
    @filled_listing = listings(:filled_listing)
    @closed_listing = listings(:closed_listing)
    @discarded_listing = listings(:discarded_listing)
    @org_one = organizations(:one)
  end

  # --- Basic loading ---

  test "homepage loads successfully" do
    get root_path
    assert_response :success
  end

  test "homepage does not require authentication" do
    get root_path
    assert_response :success
  end

  test "homepage displays open listings" do
    get root_path
    assert_response :success
    assert_match @open_listing.title, response.body
  end

  test "homepage does not display filled listings" do
    get root_path
    assert_no_match(/#{Regexp.escape(@filled_listing.title)}/, response.body)
  end

  test "homepage does not display closed listings" do
    get root_path
    assert_no_match(/#{Regexp.escape(@closed_listing.title)}/, response.body)
  end

  test "homepage does not display discarded listings" do
    get root_path
    assert_no_match(/#{Regexp.escape(@discarded_listing.title)}/, response.body)
  end

  test "homepage displays organization name for listings" do
    get root_path
    assert_match @org_one.name, response.body
  end

  test "homepage displays listing card details" do
    get root_path
    assert_match @open_listing.title, response.body
    assert_match @open_listing.commitment, response.body
    assert_match @open_listing.location, response.body
  end

  # --- Text search ---

  test "search filters listings by title" do
    get root_path, params: { query: "Rails Backend" }
    assert_response :success
    assert_match @open_listing.title, response.body
  end

  test "search excludes non-matching listings" do
    get root_path, params: { query: "nonexistent listing xyz" }
    assert_response :success
    assert_no_match(/#{Regexp.escape(@open_listing.title)}/, response.body)
  end

  test "search filters by skills" do
    get root_path, params: { query: "Ruby" }
    assert_response :success
    assert_match @open_listing.title, response.body
  end

  test "search filters by organization name" do
    get root_path, params: { query: "Code for Good" }
    assert_response :success
    assert_match @open_listing.title, response.body
  end

  test "search shows empty state when no results" do
    get root_path, params: { query: "zzzznotfound" }
    assert_response :success
    assert_match(/no listings/i, response.body)
  end

  # --- Discipline filter ---

  test "discipline filter shows matching listings" do
    get root_path, params: { discipline: "engineering" }
    assert_response :success
    assert_match @open_listing.title, response.body
  end

  test "discipline filter excludes non-matching listings" do
    # open_listing is engineering; filtering by ux_design should exclude it
    get root_path, params: { discipline: "ux_design" }
    assert_response :success
    assert_no_match(/#{Regexp.escape(@open_listing.title)}/, response.body)
  end

  test "discipline filter combined with search" do
    get root_path, params: { query: "Rails", discipline: "engineering" }
    assert_response :success
    assert_match @open_listing.title, response.body
  end

  test "discipline filter combined with search excludes non-matching" do
    get root_path, params: { query: "Rails", discipline: "ux_design" }
    assert_response :success
    assert_no_match(/#{Regexp.escape(@open_listing.title)}/, response.body)
  end

  # --- Pagination ---

  test "pagination works with many listings" do
    # Create enough listings to trigger pagination (default limit is 20)
    org = organizations(:one)
    25.times do |i|
      Listing.create!(
        title: "Paginated Listing #{i}",
        discipline: :engineering,
        commitment: "Flexible",
        location: "Remote",
        skills: "Ruby",
        status: :open,
        organization: org
      )
    end

    get root_path
    assert_response :success
    # Should have pagination nav when more than one page
    assert_select "nav.pagy" do
      assert_select "a"
    end
  end

  test "second page of pagination loads" do
    org = organizations(:one)
    25.times do |i|
      Listing.create!(
        title: "Paginated Listing #{i}",
        discipline: :engineering,
        commitment: "Flexible",
        location: "Remote",
        skills: "Ruby",
        status: :open,
        organization: org
      )
    end

    get root_path, params: { page: 2 }
    assert_response :success
  end

  # --- Empty state ---

  test "empty state shown when no open listings exist" do
    Listing.update_all(status: :closed)
    get root_path
    assert_response :success
    assert_match(/no listings/i, response.body)
  end

  # --- Search form ---

  test "homepage has search form" do
    get root_path
    assert_select "form" do
      assert_select "input[name=query]"
      assert_select "select[name=discipline]"
    end
  end
end
