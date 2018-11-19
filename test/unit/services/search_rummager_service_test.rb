require 'test_helper'
require "gds_api/test_helpers/rummager"
require_relative "../../support/search_rummager_helper"

class SearchRummagerServiceTest < ActiveSupport::TestCase
  include SearchRummagerHelper

  setup do
    @topical_event = create(:topical_event, :active)
    @world_location = create(:world_location)
  end

  test 'returns empty results array if topical event has no documents' do
    stub_any_rummager_search_to_return_no_results
    assert_equal [], SearchRummagerService.new.fetch_related_documents(topical_params)['results']
  end

  test 'fetches documents related to a topical event' do
    stub_any_rummager_search.to_return(body: rummager_response)
    results = SearchRummagerService.new.fetch_related_documents(topical_params)['results']

    assert_instance_of RummagerDocumentPresenter, results.first
    assert_equal 4, results.count
    assert_equal attributes(processed_rummager_documents),
                 attributes(results)
  end

  test 'search receives correct params for a topical event' do
    expected_search_params(topical_params)
  end

  test 'search receives correct params for a world_location' do
    expected_search_params(world_params)
  end

  test 'setting count replaces the default count of 1000' do
    expected_search_params(count: 3)
  end

  test 'search receives multiple additional params' do
    expected_search_params(world_params.merge(filter_format: 'publication', count: 3))
  end

  def expected_search_params(params = {})
    Whitehall
      .search_client
      .expects(:search)
      .with(default_search_options.merge(params))
      .returns('results' => [])

    SearchRummagerService.new.fetch_related_documents(params)
  end

  def topical_params
    {
      filter_topical_events: @topical_event.slug,
      reject_any_content_store_document_type: 'news_article'
    }
  end

  def world_params
    {
      filter_world_locations: @world_location.slug,
    }
  end

  def default_search_options
    {
      order: "-public_timestamp",
      count: 1000,
      fields: %w[display_type title link public_timestamp format content_store_document_type
                 description content_id organisations document_collections]
    }
  end
end
