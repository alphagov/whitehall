require 'test_helper'

class Api::MainstreamCategoryTagPresenterTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  def default_url_options
    {host: "example.com"}
  end

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
    assert_equal mainstream_category_path(category, host: 'govuk.example.com'), json[:content_with_tag][:web_url]
  end
end
