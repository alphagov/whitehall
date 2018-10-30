require 'test_helper'

module Whitehall::DocumentFilter
  class SearchRummagerTest < ActiveSupport::TestCase
    setup do
      Whitehall.search_client.stubs(:search).returns {}
    end

    ANNOUNCEMENT_TYPES = %w[
      press_release
      news_article
      news_story
      fatality_notice
      speech
      written_statement
      oral_statement
      authored_article
      government_response
    ].freeze

    WORLD_ANNOUNCEMENT_TYPES = %w[world_location_news_article world_news_story].freeze

    def format_types(*classes)
      classes.map(&:search_format_type)
    end

    def expect_search_by_content_store_document_type(document_types)
      Whitehall
        .search_client
        .expects(:search)
        .with(
          has_entry(
            filter_content_store_document_type: document_types
          )
        )
    end

    def expect_search_by_taxonomy_tree(taxons)
      Whitehall
          .search_client
          .expects(:search)
          .with(
            has_entry(
              filter_part_of_taxonomy_tree: taxons
            )
          )
    end

    def expect_search_by_people(people)
      Whitehall
        .search_client
        .expects(:search)
        .with(
          has_entry(filter_people: people)
        )
    end

    def expect_search_by_topical_event(topical_event)
      Whitehall
        .search_client
        .expects(:search)
        .with(
          has_entry(filter_topical_events: topical_event)
        )
    end

    test 'announcements_search looks for all announcements excluding world types by default' do
      rummager = SearchRummager.new({})
      expected_types = ANNOUNCEMENT_TYPES
      expect_search_by_content_store_document_type(expected_types)
      rummager.announcements_search
    end

    test 'announcements_search looks for all Announcements if we need to include world location news' do
      rummager = SearchRummager.new(include_world_location_news: '1')
      expected_types = WORLD_ANNOUNCEMENT_TYPES + ANNOUNCEMENT_TYPES
      expect_search_by_content_store_document_type(expected_types)
      rummager.announcements_search
    end

    test 'announcements_search looks for a specific announcement sub type if we use the announcement_type option' do
      rummager = SearchRummager.new(announcement_type: 'government-responses')
      expect_search_by_content_store_document_type("government_response")
      rummager.announcements_search
    end

    test 'announcements_search looks for announcements that are associated with a person if we use the people option' do
      rummager = SearchRummager.new(people: 'jane-doe')
      expect_search_by_people(["jane-doe"])
      rummager.announcements_search
    end

    test 'announcements_search search the taxonomy tree if we use the taxons option' do
      rummager = SearchRummager.new(taxons: 'content-id')
      expect_search_by_taxonomy_tree(%w[content-id])
      rummager.announcements_search
    end

    test 'announcements_search looks for announcements associated with a Topical Event' do
      topical_event = create(:topical_event)
      rummager = SearchRummager.new(topics: topical_event.slug)
      expect_search_by_topical_event([topical_event.slug])
      rummager.announcements_search
    end

    test 'documents returns a paginated array' do
      rummager = SearchRummager.new({})
      rummager.announcements_search
      assert_kind_of Kaminari::PaginatableArray, rummager.documents
    end
  end
end
