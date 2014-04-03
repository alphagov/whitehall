require 'test_helper'

module Whitehall::DocumentFilter
  class FiltererTest < ActiveSupport::TestCase

    test "parses a valid from_date" do
      assert_equal Date.new(2008, 2, 28), build_filter(from_date: '28th February 2008').from_date
    end

    test "parses a valid to_date" do
      assert_equal Date.new(2013, 5, 2), build_filter(to_date: '2 May 2013').to_date
    end

    test "invalid date params are ignored" do
      assert_equal nil, build_filter(from_date: "invalid-date").from_date
    end

    test "dates before 1900 are ignored" do
      assert_equal nil, build_filter(from_date: "2 February 200").from_date
    end

    test "page defaults to the first page" do
      assert_equal 3, build_filter(page: 3).page
      assert_equal 1, build_filter.page
    end

    test "per_page defaults to 40" do
      assert_equal 10, build_filter(per_page: 10).per_page
      assert_equal 40, build_filter().per_page
    end

    test "parses keywords, stripping leading and trailing spaces" do
      filter = build_filter(keywords: " alpha   beta ")
      assert_equal ['alpha', 'beta'], filter.keywords
    end

    test "publication_filter_option param sets the filter option with a slug" do
      filter_option = Whitehall::PublicationFilterOption::ClosedConsultation
      filter = build_filter(publication_filter_option: filter_option.slug)

      assert_equal filter_option, filter.selected_publication_filter_option
    end

    test "publication_type param also sets the filter option for backwards compatibility" do
      filter_option = Whitehall::PublicationFilterOption::PolicyPaper
      filter = build_filter(publication_type: filter_option.slug)

      assert_equal filter_option, filter.selected_publication_filter_option
    end

    test "publication_filter_option takes precedence over publication_type param" do
      filter_option = Whitehall::PublicationFilterOption::Statistics
      filter = build_filter(publication_type: 'foobar', publication_filter_option: filter_option.slug)

      assert_equal filter_option, filter.selected_publication_filter_option
    end

  private

    def build_filter(args={})
      Whitehall::DocumentFilter::Filterer.new(args)
    end
  end
end
