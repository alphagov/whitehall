require 'test_helper'

module Whitehall::DocumentFilter
  class SearchRummagerTest < ActiveSupport::TestCase
    setup do
      Whitehall.search_client.stubs(:search).returns {}
    end

    def format_types(*classes)
      classes.map(&:search_format_type)
    end

    def expect_search_by_format_types(format_types)
      Whitehall
        .search_client
        .expects(:search)
        .with(
          has_entry(
            filter_search_format_types: format_types
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

    test 'announcements_search looks for all announcements excluding world types by default' do
      rummager = SearchRummager.new({})
      expected_types = [
        "fatality-notice",
        "speech",
        "news-article-news-story",
        "news-article-press-release",
        "news-article-government-response",
      ]
      expect_search_by_format_types(expected_types)
      rummager.announcements_search
    end

    test 'announcements_search looks for all Announcements if we need to include world location news' do
      rummager = SearchRummager.new(include_world_location_news: '1')
      expected_types = %w[
        announcement
      ]
      expect_search_by_format_types(expected_types)
      rummager.announcements_search
    end

    test 'announcements_search looks for a specific announcement sub type if we use the announcement_type option' do
      rummager = SearchRummager.new(announcement_type: 'government-responses')
      expect_search_by_format_types(NewsArticleType::GovernmentResponse.search_format_types)
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

    test 'documents returns a paginated array' do
      rummager = SearchRummager.new({})
      rummager.announcements_search
      assert_kind_of Kaminari::PaginatableArray, rummager.documents
    end
  end
end
