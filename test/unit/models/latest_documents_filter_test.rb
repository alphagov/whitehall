require 'test_helper'

class LatestDocumentsFilterTest < ActiveSupport::TestCase
  class FauxFilter < LatestDocumentsFilter
  private
    def documents_source
      subject.published_editions
    end
  end

  test '.for_subject should return an instance of ClassificationFilter for a topic' do
    topic = create(:topic)
    filter = LatestDocumentsFilter.for_subject(topic)

    assert filter.is_a?(LatestDocumentsFilter::ClassificationFilter)
  end

  test '.for_subject should return an instance of ClassificationFilter for a topical event' do
    topical_event = create(:topical_event)
    filter = LatestDocumentsFilter.for_subject(topical_event)

    assert filter.is_a?(LatestDocumentsFilter::ClassificationFilter)
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
    organisation = create(:organisation)
    5.times { create(:published_detailed_guide, organisations: [organisation]) }
    filter = FauxFilter.new(organisation, page: 2, per_page: 2)

    assert_equal 2, filter.documents.current_page
    assert_equal 2, filter.documents.length
    assert_equal 3, filter.documents.total_pages
    assert_equal 5, filter.documents.total_count
    refute filter.documents.first_page?
    refute filter.documents.last_page?
  end

  test '#documents should default to the first page of 40 results if pagination settings are not provided' do
    organisation = create(:organisation)
    50.times { create(:published_detailed_guide, organisations: [organisation]) }
    filter = FauxFilter.new(organisation)

    assert_equal 1, filter.documents.current_page
    assert_equal 40, filter.documents.length
  end
end

class OrganisationFilterTest < ActiveSupport::TestCase
  test '#documents should return a list of documents for the organisation' do
    expected = [
      document(:detailed_guide, first_published_at: 1.days.ago),
      document(:policy_paper, first_published_at: 2.days.ago),
      document(:policy, first_published_at: 3.days.ago),
      document(:consultation, opening_at: 4.days.ago),
      document(:statistics, first_published_at: 5.days.ago),
    ]

    filter = LatestDocumentsFilter::OrganisationFilter.new(organisation)

    assert_equal expected, filter.documents
  end

private
  def organisation
    @organisation ||= create(:organisation)
  end

  def document(document_type, attributes = {})
    create("published_#{document_type}",
           attributes.merge(organisations: [organisation]))
  end
end

class WorldLocationFilterTest < ActiveSupport::TestCase
  test '#documents should return a list of documents for the world location' do
    expected = [
      document(:detailed_guide, first_published_at: 1.days.ago),
      document(:policy_paper, first_published_at: 2.days.ago),
      document(:policy, first_published_at: 3.days.ago),
      document(:consultation, opening_at: 4.days.ago),
      document(:statistics, first_published_at: 5.days.ago),
    ]

    filter = LatestDocumentsFilter::WorldLocationFilter.new(world_location)

    assert_equal expected, filter.documents
  end

private
  def world_location
    @world_location ||= create(:world_location)
  end

  def document(document_type, attributes = {})
    create("published_#{document_type}",
           attributes.merge(world_locations: [world_location]))
  end
end

class ClassificationFilterTest < ActiveSupport::TestCase
  test '#documents should return a list of documents for the topic' do
    expected = [
      document(:detailed_guide, first_published_at: 1.days.ago),
      document(:policy_paper, first_published_at: 2.days.ago),
      document(:policy, first_published_at: 3.days.ago),
      document(:consultation, opening_at: 4.days.ago),
      document(:statistics, first_published_at: 5.days.ago),
    ]

    filter = LatestDocumentsFilter::ClassificationFilter.new(topic)

    assert_equal expected, filter.documents
  end

  test '#documents should not include world location news articles' do
    document(:world_location_news_article)
    filter = LatestDocumentsFilter::ClassificationFilter.new(topic)

    assert_equal [], filter.documents
  end

private
  def topic
    @topic ||= create(:topic)
  end

  def document(document_type, attributes = {})
    create("published_#{document_type}", attributes.merge(topics: [topic]))
  end
end
