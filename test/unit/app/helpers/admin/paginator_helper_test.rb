require "test_helper"

class Admin::PaginationHelperTest < ActionView::TestCase
  setup do
    @organisation = build_stubbed(:organisation)
  end

  test "#pagination_hash returns nil if only one page of objects" do
    assert_nil Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 1, path: path_for_page(1))
  end

  test "#pagination_hash when total pages are less than 5 it returns the correct objects" do
    expected_hash = {
      previous_page: {
        href: path_for_page(2),
      },
      next_page: {
        href: path_for_page(4),
      },
      items: [
        {
          href: path_for_page(1),
          current: false,
          number: 1,
        },
        {
          href: path_for_page(2),
          current: false,
          number: 2,
        },
        {
          href: path_for_page(3),
          current: true,
          number: 3,
        },
        {
          href: path_for_page(4),
          current: false,
          number: 4,
        },
        {
          href: path_for_page(5),
          current: false,
          number: 5,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 3, total_pages: 5, path: path_for_page(3))
  end

  [*1..3].each do |page|
    test "#pagination_hash returns the correct ouput when the current page is #{page} of 10" do
      expected_hash = {
        next_page: {
          href: path_for_page(page + 1),
        },
        items: [
          {
            href: path_for_page(1),
            current: page == 1,
            number: 1,
          },
          {
            href: path_for_page(2),
            current: page == 2,
            number: 2,
          },
          {
            href: path_for_page(3),
            current: page == 3,
            number: 3,
          },
          {
            href: path_for_page(4),
            current: false,
            number: 4,
          },
          {
            ellipsis: true,
          },
          {
            href: path_for_page(10),
            current: false,
            number: 10,
          },
        ],
      }.merge(
        page > 1 ? {
          previous_page: {
            href: path_for_page(page - 1),
          },
        } : {},
      )

      assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))
    end
  end

  [*4..7].each do |page|
    test "#pagination_hash returns the correct ouput when the current page is #{page} of 10" do
      expected_hash = {
        previous_page: {
          href: path_for_page(page - 1),
        },
        next_page: {
          href: path_for_page(page + 1),
        },
        items: [
          {
            href: path_for_page(1),
            current: false,
            number: 1,
          },
          {
            ellipsis: true,
          },
          {
            href: path_for_page(page - 1),
            current: false,
            number: page - 1,
          },
          {
            href: path_for_page(page),
            current: true,
            number: page,
          },
          {
            href: path_for_page(page + 1),
            current: false,
            number: page + 1,
          },
          {
            ellipsis: true,
          },
          {
            href: path_for_page(10),
            current: false,
            number: 10,
          },
        ],
      }

      assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))
    end
  end

  [*8..10].each do |page|
    test "#pagination_hash returns the correct ouput when the current page is #{page} of 10" do
      expected_hash = {
        previous_page: {
          href: path_for_page(page - 1),
        },
        items: [
          {
            href: path_for_page(1),
            current: false,
            number: 1,
          },
          {
            ellipsis: true,
          },
          {
            href: path_for_page(7),
            current: page == 7,
            number: 7,
          },
          {
            href: path_for_page(8),
            current: page == 8,
            number: 8,
          },
          {
            href: path_for_page(9),
            current: page == 9,
            number: 9,
          },
          {
            href: path_for_page(10),
            current: page == 10,
            number: 10,
          },
        ],
      }.merge(
        page < 10 ? {
          next_page: {
            href: path_for_page(page + 1),
          },
        } : {},
      )

      assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))
    end
  end

  test "#pagination_hash when a path with no query string params is passed in it still constucts the pagination links correctly" do
    path = admin_organisation_corporate_information_pages_path(@organisation)

    expected_hash = {
      next_page: {
        href: path_for_page(2),
      },
      items: [
        {
          href: path_for_page(1),
          current: true,
          number: 1,
        },
        {
          href: path_for_page(2),
          current: false,
          number: 2,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 2, path:)
  end

  test "#pagination_hash when a path with no per_page query param is passed in it still constucts the pagination links correctly" do
    path = admin_organisation_corporate_information_pages_path(@organisation, random_query_string: "random")

    expected_hash = {
      next_page: {
        href: "#{path}&page=2",
      },
      items: [
        {
          href: "#{path}&page=1",
          current: true,
          number: 1,
        },
        {
          href: "#{path}&page=2",
          current: false,
          number: 2,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 2, path:)
  end

  test "#pagination_hash when the request has an anchor and but query strings it constructs the url correctly" do
    path = "#{admin_organisation_corporate_information_pages_path(@organisation)}#document_tab"

    expected_hash = {
      next_page: {
        href: "#{path_for_page(2)}#document_tab",
      },
      items: [
        {
          href: "#{path_for_page(1)}#document_tab",
          current: true,
          number: 1,
        },
        {
          href: "#{path_for_page(2)}#document_tab",
          current: false,
          number: 2,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 2, path:)
  end

  test "#pagination_hash when the request has an anchor but and query strings it constructs the url correctly" do
    path = "#{admin_organisation_corporate_information_pages_path(@organisation, random_query_string: 'random')}#document_tab"
    base_path = admin_organisation_corporate_information_pages_path(@organisation, random_query_string: "random")

    expected_hash = {
      next_page: {
        href: "#{base_path}&page=2#document_tab",
      },
      items: [
        {
          href: "#{base_path}&page=1#document_tab",
          current: true,
          number: 1,
        },
        {
          href: "#{base_path}&page=2#document_tab",
          current: false,
          number: 2,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 2, path:)
  end

  def path_for_page(page)
    admin_organisation_corporate_information_pages_path(@organisation, page:)
  end
end
