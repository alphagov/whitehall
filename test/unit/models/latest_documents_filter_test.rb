require 'test_helper'
require "gds_api/test_helpers/rummager"
require_relative "../../support/search_rummager_helper"

class LatestDocumentsFilterTest < ActiveSupport::TestCase
  include SearchRummagerHelper

  test '.for_subject should return an instance of TopicalEventFilter for a topical event' do
    topical_event = create(:topical_event)
    filter = LatestDocumentsFilter.for_subject(topical_event)

    assert filter.is_a?(LatestDocumentsFilter::TopicalEventFilter)
  end

  test '.for_subject should return an instance of OrganisationFilter for an organisation' do
    organisation = create(:organisation)
    filter = LatestDocumentsFilter.for_subject(organisation)

    assert filter.is_a?(LatestDocumentsFilter::OrganisationFilter)
  end

  test '.for_subject should return an instance of WorldLocationFilter for a worldwide location' do
    world_location = create(:world_location)
    filter = LatestDocumentsFilter.for_subject(world_location)

    assert filter.is_a?(LatestDocumentsFilter::WorldLocationFilter)
  end

  test '#documents should return paginated results' do
    topical_event = create(:topical_event)
    stub_any_rummager_search.to_return(body: rummager_response)
    filter = LatestDocumentsFilter::TopicalEventFilter.new(
      topical_event, page: 2, per_page: 2
    )

    assert_equal 2, filter.documents.current_page
    assert_equal 2, filter.documents.length
    assert_equal 2, filter.documents.total_pages
    assert_equal 4, filter.documents.total_count
  end

  test '#documents should default to the first page of 40 results if pagination settings are not provided' do
    topical_event = create(:topical_event)

    results = {}
    results['results'] = (1..50).map do
      {
        'link' => 'linky link',
        'title' => 'titley title',
        'display_type' => 'display typey'
      }
    end

    stub_any_rummager_search.to_return(body: results.to_json)

    filter = LatestDocumentsFilter::TopicalEventFilter.new(topical_event)

    assert_equal 1, filter.documents.current_page
    assert_equal 40, filter.documents.length
  end
end

class OrganisationFilterTest < ActiveSupport::TestCase
  include SearchRummagerHelper

  test '#documents should return a list of documents for the organisation' do
    filter = LatestDocumentsFilter::OrganisationFilter.new(organisation)

    search_rummager_service_stub(
      filter_organisations: organisation.slug,
      reject_any_format: %w[corporate_information_page
                            minister
                            organisation
                            person
                            statistics_announcement
                            topical_event]
    )

    assert_equal attributes(processed_rummager_documents), attributes(filter.documents)
  end

private

  def organisation
    @organisation ||= create(:organisation)
  end
end

class WorldLocationFilterTest < ActiveSupport::TestCase
  include SearchRummagerHelper

  test '#documents should return a list of documents for the world location' do
    filter = LatestDocumentsFilter::WorldLocationFilter.new(world_location)

    search_rummager_service_stub(
      filter_world_locations: world_location.slug,
    )

    assert_equal attributes(processed_rummager_documents), attributes(filter.documents)
  end

private

  def world_location
    @world_location ||= create(:world_location)
  end
end

class TopicalEventFilterTest < ActiveSupport::TestCase
  include SearchRummagerHelper

  test '#documents should return a list of documents for the topical event' do
    filter = LatestDocumentsFilter::TopicalEventFilter.new(topic)

    search_rummager_service_stub(
      filter_topical_events: topic.slug,
      reject_any_content_store_document_type: 'news_article'
    )

    assert_equal attributes(processed_rummager_documents), attributes(filter.documents)
  end

private

  def topic
    @topic ||= create(:topic)
  end
end
