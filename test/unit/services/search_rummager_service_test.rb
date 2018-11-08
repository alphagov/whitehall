require 'test_helper'
require "gds_api/test_helpers/rummager"
require_relative "../../support/search_rummager_helper"

class SearchRummagerServiceTest < ActiveSupport::TestCase
  include SearchRummagerHelper

  setup do
    @topical_event = create(:topical_event, :active)
  end

  test 'returns empty results array if topical event has no documents' do
    stub_any_rummager_search_to_return_no_results
    assert_equal [], SearchRummagerService.new.fetch_related_documents(topical_param)['results']
  end

  test 'fetches documents related to a topical event' do
    stub_any_rummager_search.to_return(body: rummager_response)

    results = SearchRummagerService.new.fetch_related_documents(topical_param)['results']

    assert_instance_of RummagerDocumentPresenter, results.first
    assert_equal 4, results.count
    assert_equal attributes(processed_rummager_documents),
                 attributes(results)
  end

  def topical_param
    { filter_topical_events: @topical_event.slug }
  end
end
