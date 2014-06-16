require 'test_helper'

class Api::MainstreamCategoryTagPresenterTest < ActiveSupport::TestCase
  test "json includes list of results" do
    results = [create(:mainstream_category), create(:mainstream_category), create(:mainstream_category)]
    results = Api::MainstreamCategoryTagPresenter.new(results)
    assert_equal results.as_json[:results].length, 3
  end

  test "json result includes web_url and title" do
    category = create(:mainstream_category)
    results = [category]
    results = Api::MainstreamCategoryTagPresenter.new(results)
    json = results.as_json[:results].first

    assert_equal category.title, json[:title]
    assert_equal Whitehall.url_maker.mainstream_category_path(category), json[:content_with_tag][:web_url]
  end

  test "json result includes description" do
    category = create(:mainstream_category)
    results = [category]
    results = Api::MainstreamCategoryTagPresenter.new(results)
    json = results.as_json[:results].first

    assert_equal category.description, json[:details][:description]
  end
end
