require 'test_helper'

module Whitehall::DocumentFilter
  class RummagerTest < ActiveSupport::TestCase

    setup do
      Whitehall.government_search_client.stubs(:advanced_search).returns {}
    end

    def format_types(*classes)
      classes.map { |cls| cls.search_format_type }
    end

    def expect_search_by_format_types(format_types)
      Whitehall.government_search_client.expects(:advanced_search).with(
          has_entry({ search_format_types: format_types }))
    end

    test 'announcements_search looks for NewsArticles, FatalityNotices and Speeches by default' do
      rummager = Rummager.new({})
      expect_search_by_format_types(format_types(FatalityNotice, NewsArticle, Speech))
      rummager.announcements_search
    end

    test 'announcements_search looks for all Announcements if we need to include world location news' do
      rummager = Rummager.new({include_world_location_news: '1'})
      expect_search_by_format_types(format_types(Announcement))
      rummager.announcements_search
    end

    test 'announcements_search looks for a specific announcement sub type if we use the announcement_type option' do
      rummager = Rummager.new({announcement_type: 'government-responses'})
      expect_search_by_format_types(NewsArticleType::GovernmentResponse.search_format_types)
      rummager.announcements_search
    end

    test 'publications_search looks for Publications, Consultations, and StatisticalDataSets by default' do
      rummager = Rummager.new({})
      expect_search_by_format_types(format_types(Consultation, Publication, StatisticalDataSet))
      rummager.publications_search
    end

    test 'publications_search looks for a specific announcement sub type if we use the publication_type option' do
      rummager = Rummager.new({publication_type: 'policy-papers'})
      expect_search_by_format_types(PublicationType::PolicyPaper.search_format_types)
      rummager.publications_search
    end

    test 'policies_search looks for Policy documents' do
      rummager = Rummager.new({})
      expect_search_by_format_types(format_types(Policy))
      rummager.policies_search
    end

    test 'documents returns a paginated array' do
      rummager = Rummager.new({})
      rummager.announcements_search
      assert_kind_of Kaminari::PaginatableArray, rummager.documents
    end
  end
end
