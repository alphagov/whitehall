require 'test_helper'

class CollectionPageTest < ActiveSupport::TestCase
  def build(collection_subset, options = {})
    CollectionPage.new(collection_subset, options)
  end

  test "it should behave like an array" do
    collection_page = build([:something, :something_else])
    assert_equal :something, collection_page[0]
    assert_equal :something_else, collection_page[1]
    assert collection_page.respond_to?(:each)
  end

  test "it should hold total, page and per_page attributes" do
    collection_page = build((1..20).to_a, total: 30, page: 2, per_page: 20)

    assert_equal 30, collection_page.total
    assert_equal 2, collection_page.page
    assert_equal 20, collection_page.per_page
  end

  test "#number_of_pages should calculate the correct number of pages from the total" do
    collection_page = build((1..10).to_a, total: 33, page: 2, per_page: 10)
    assert_equal 4, collection_page.number_of_pages
  end

  test "#next_page? return true if there is a next page available" do
    assert build([], total: 2, page: 1, per_page: 1).next_page?
    refute build([], total: 2, page: 2, per_page: 1).next_page?
  end

  test "#previous_page? return true if there is a previous page available" do
    assert build([], total: 2, page: 2, per_page: 1).previous_page?
    refute build([], total: 2, page: 1, per_page: 1).previous_page?
  end
end
