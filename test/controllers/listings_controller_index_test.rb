require "test_helper"

class ListingsControllerIndexTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get listings_path
    assert_response :success
  end

  test "index shows available listings" do
    get listings_path
    assert_match listings(:open_listing).title, response.body
  end

  test "index does not show filled listings" do
    get listings_path
    assert_no_match listings(:filled_listing).title, response.body
  end

  test "index does not show closed listings" do
    get listings_path
    assert_no_match listings(:closed_listing).title, response.body
  end

  test "index does not show discarded listings" do
    get listings_path
    assert_no_match listings(:discarded_listing).title, response.body
  end

  test "index filters by discipline" do
    get listings_path(discipline: "engineering")
    assert_match listings(:open_listing).title, response.body
  end

  test "index filters out non-matching disciplines" do
    get listings_path(discipline: "marketing")
    assert_no_match listings(:open_listing).title, response.body
  end

  test "index searches by title" do
    get listings_path(query: "Rails Backend")
    assert_match listings(:open_listing).title, response.body
  end

  test "index searches by organization name" do
    get listings_path(query: listings(:open_listing).organization.name)
    assert_match listings(:open_listing).title, response.body
  end

  test "index searches by skills" do
    get listings_path(query: "PostgreSQL")
    assert_match listings(:open_listing).title, response.body
  end

  test "index search excludes non-matching results" do
    get listings_path(query: "nonexistenttermxyz")
    assert_no_match listings(:open_listing).title, response.body
  end

  test "index combines search and discipline filter" do
    get listings_path(query: "Rails", discipline: "engineering")
    assert_match listings(:open_listing).title, response.body
  end

  test "index renders empty state when no results" do
    get listings_path(query: "nonexistenttermxyz")
    assert_match "No listings found", response.body
  end

  test "index shows discipline sidebar links" do
    get listings_path
    Listing.disciplines.keys.each do |discipline|
      assert_match discipline.titleize, response.body
    end
  end

  test "index appears accessible without authentication" do
    get listings_path
    assert_response :success
  end
end
