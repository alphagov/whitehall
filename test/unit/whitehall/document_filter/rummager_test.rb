require 'test_helper'

module Whitehall::DocumentFilter
  class RummagerTest < ActiveSupport::TestCase

    setup do
      Whitehall.government_search_client.stubs(:advanced_search).returns []
    end

    test 'announcements_search looks for NewsArticles, FatalityNotices and Speeches by default' do
      r = Rummager.new({})
      expected_search_formats = [NewsArticle.search_format_type, Speech.search_format_type, FatalityNotice.search_format_type]
      Whitehall.government_search_client.expects(:advanced_search).with(has_entry(search_format_types: expected_search_formats))
      r.announcements_search
    end

    test 'announcements_search looks for all Announcements if we need to include world location news' do
      r = Rummager.new({include_world_location_news: '1'})
      expected_search_formats = [Announcement.search_format_type]
      Whitehall.government_search_client.expects(:advanced_search).with(has_entry(search_format_types: expected_search_formats))
      r.announcements_search
    end

    test 'announcements_search looks for a specific announcement sub type if we use the announcement_type option' do
      r = Rummager.new({announcement_type: 'government-responses'})
      expected_search_formats = NewsArticleType::GovernmentResponse.search_format_types
      Whitehall.government_search_client.expects(:advanced_search).with(has_entry(search_format_types: expected_search_formats))
      r.announcements_search
    end

    test 'announcements_search will eager load document and organisations' do
      r = Rummager.new({})
      r.announcements_search
      assert_equal [:document, :organisations], r.edition_eager_load
    end

    test 'publications_search looks for Publications, Consultations, and StatisticalDataSets by default' do
      r = Rummager.new({})
      expected_search_formats = [Publication.search_format_type, Consultation.search_format_type, StatisticalDataSet.search_format_type]
      Whitehall.government_search_client.expects(:advanced_search).with(has_entry(search_format_types: expected_search_formats))
      r.publications_search
    end

    test 'publications_search looks for a specific announcement sub type if we use the announcement_type option' do
      r = Rummager.new({publication_type: 'policy-papers'})
      expected_search_formats = PublicationType::PolicyPaper.search_format_types
      Whitehall.government_search_client.expects(:advanced_search).with(has_entry(search_format_types: expected_search_formats))
      r.publications_search
    end

    test 'publications_search will eager load document and organisations' do
      r = Rummager.new({})
      r.publications_search
      assert_equal [:document, :organisations], r.edition_eager_load
    end

    test 'policies_search looks for Policy documents' do
      r = Rummager.new({})
      expected_search_formats = [Policy.search_format_type]
      Whitehall.government_search_client.expects(:advanced_search).with(has_entry(search_format_types: expected_search_formats))
      r.policies_search
    end

    test 'policies_search will eager load document and organisations' do
      r = Rummager.new({})
      r.policies_search
      assert_equal [:document, :organisations], r.edition_eager_load
    end

  end
end