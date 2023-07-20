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
      previous_href: path_for_page(2),
      next_href: path_for_page(4),
      items: [
        {
          href: path_for_page(1),
          current: false,
        },
        {
          href: path_for_page(2),
          current: false,
        },
        {
          href: path_for_page(3),
          current: true,
        },
        {
          href: path_for_page(4),
          current: false,
        },
        {
          href: path_for_page(5),
          current: false,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 3, total_pages: 5, path: path_for_page(3))
  end

  [*1..3].each do |page|
    test "#pagination_hash returns the correct ouput when the current page is #{page} of 10" do
      expected_hash = {
        previous_href: page > 1 ? path_for_page(page - 1) : nil,
        next_href: path_for_page(page + 1),
        items: [
          {
            href: path_for_page(1),
            label: "1",
            current: page == 1,
          },
          {
            href: path_for_page(2),
            label: "2",
            current: page == 2,
          },
          {
            href: path_for_page(3),
            label: "3",
            current: page == 3,
          },
          {
            href: path_for_page(4),
            label: "4",
            current: false,
          },
          {
            ellipses: true,
          },
          {
            href: path_for_page(10),
            label: "10",
            current: false,
          },
        ],
      }

      assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))
    end
  end

  [*4..7].each do |page|
    test "#pagination_hash returns the correct ouput when the current page is #{page} of 10" do
      expected_hash = {
        previous_href: path_for_page(page - 1),
        next_href: path_for_page(page + 1),
        items: [
          {
            href: path_for_page(1),
            label: "1",
            current: false,
          },
          {
            ellipses: true,
          },
          {
            href: path_for_page(page - 1),
            label: (page - 1).to_s,
            current: false,
          },
          {
            href: path_for_page(page),
            label: page.to_s,
            current: true,
          },
          {
            href: path_for_page(page + 1),
            label: (page + 1).to_s,
            current: false,
          },
          {
            ellipses: true,
          },
          {
            href: path_for_page(10),
            label: "10",
            current: false,
          },
        ],
      }

      assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))
    end
  end

  [*8..10].each do |page|
    test "#pagination_hash returns the correct ouput when the current page is #{page} of 10" do
      expected_hash = {
        previous_href: path_for_page(page - 1),
        next_href: page == 10 ? nil : path_for_page(page + 1),
        items: [
          {
            href: path_for_page(1),
            label: "1",
            current: false,
          },
          {
            ellipses: true,
          },
          {
            href: path_for_page(7),
            label: "7",
            current: page == 7,
          },
          {
            href: path_for_page(8),
            label: "8",
            current: page == 8,
          },
          {
            href: path_for_page(9),
            label: "9",
            current: page == 9,
          },
          {
            href: path_for_page(10),
            label: "10",
            current: page == 10,
          },
        ],
      }

      assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))
    end
  end

  test "#pagination_hash when a path with no query string params is passed in it still constucts the pagination links correctly" do
    path = admin_organisation_corporate_information_pages_path(@organisation)

    expected_hash = {
      previous_href: nil,
      next_href: path_for_page(2),
      items: [
        {
          href: path_for_page(1),
          current: true,
        },
        {
          href: path_for_page(2),
          current: false,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 2, path:)
  end

  test "#pagination_hash when a path with no per_page query param is passed in it still constucts the pagination links correctly" do
    path = admin_organisation_corporate_information_pages_path(@organisation, random_query_string: "random")

    expected_hash = {
      previous_href: nil,
      next_href: "#{path}&page=2",
      items: [
        {
          href: "#{path}&page=1",
          current: true,
        },
        {
          href: "#{path}&page=2",
          current: false,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 2, path:)
  end

  test "#pagination_hash when the request has an anchor and but query strings it constructs the url correctly" do
    path = "#{admin_organisation_corporate_information_pages_path(@organisation)}#document_tab"

    expected_hash = {
      previous_href: nil,
      next_href: "#{path_for_page(2)}#document_tab",
      items: [
        {
          href: "#{path_for_page(1)}#document_tab",
          current: true,
        },
        {
          href: "#{path_for_page(2)}#document_tab",
          current: false,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 2, path:)
  end

  test "#pagination_hash when the request has an anchor but and query strings it constructs the url correctly" do
    path = "#{admin_organisation_corporate_information_pages_path(@organisation, random_query_string: 'random')}#document_tab"
    base_path = admin_organisation_corporate_information_pages_path(@organisation, random_query_string: "random")

    expected_hash = {
      previous_href: nil,
      next_href: "#{base_path}&page=2#document_tab",
      items: [
        {
          href: "#{base_path}&page=1#document_tab",
          current: true,
        },
        {
          href: "#{base_path}&page=2#document_tab",
          current: false,
        },
      ],
    }

    assert_equal expected_hash, Admin::PaginationHelper.pagination_hash(current_page: 1, total_pages: 2, path:)
  end

  def path_for_page(page)
    admin_organisation_corporate_information_pages_path(@organisation, page:)
  end
end
