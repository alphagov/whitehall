require "test_helper"

class PaginationTest < ActionView::TestCase
  test "should render component" do
    render("components/pagination")

    assert_select ".app-c-pagination", count: 1
  end

  test "should render component with only items" do
    list_items = [
      {
        href: "/page/1",
      },
      {
        href: "/page/2",
      },
      {
        href: "/page/3",
      },
    ]

    render("components/pagination", {
      items: list_items,
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__prev", count: 0
    assert_select ".govuk-pagination__next", count: 0
    assert_select ".govuk-pagination__item", count: 3
    assert_select ".govuk-pagination__item .govuk-pagination__link" do |elements|
      list_items.each_with_index do |item, index|
        assert_equal elements[index].text, (index + 1).to_s
        assert_equal elements[index].attr("aria-label"), "Page #{index + 1}"
        assert_equal elements[index].attr("href"), item[:href]
      end
    end
  end

  test "should render component with current page" do
    render("components/pagination", {
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
          current: true,
        },
        {
          href: "/page/3",
        },
      ],
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__item", count: 3
    assert_select ".govuk-pagination__item--current", count: 1
    assert_select ".govuk-pagination__item--current", text: "2"
    assert_select ".govuk-pagination__item--current .govuk-pagination__link" do |current_link|
      assert_equal current_link.first.attr("aria-current"), "page"
    end
  end

  test "should render component with previous and next links" do
    render("components/pagination", {
      previous_href: "/page/1",
      next_href: "/page/3",
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
        },
        {
          href: "/page/3",
        },
      ],
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__item", count: 3
    assert_select ".govuk-pagination__prev", count: 1
    assert_select ".govuk-pagination__next", count: 1
  end

  test "should render component with only previous links" do
    render("components/pagination", {
      previous_href: "/page/1",
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
        },
        {
          href: "/page/3",
        },
      ],
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__item", count: 3
    assert_select ".govuk-pagination__prev", count: 1
    assert_select ".govuk-pagination__next", count: 0
  end

  test "should render component with only next links" do
    render("components/pagination", {
      next_href: "/page/3",
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
        },
        {
          href: "/page/3",
        },
      ],
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__item", count: 3
    assert_select ".govuk-pagination__prev", count: 0
    assert_select ".govuk-pagination__next", count: 1
  end

  test "should render component with custom labels" do
    list_items = [
      {
        label: "This is page 1.1",
        href: "/page/1.1",
      },
      {
        label: "This is page 1.2",
        href: "/page/1.2",
      },
      {
        label: "This is page 1.2",
        href: "/page/1.2",
      },
    ]

    render("components/pagination", {
      items: list_items,
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__item", count: 3
    assert_select(".govuk-pagination__item .govuk-pagination__link") do |elements|
      list_items.each_with_index do |item, index|
        assert_equal elements[index].text, item[:label]
        assert_equal elements[index].attr("aria-label"), item[:label]
        assert_equal elements[index].attr("href"), item[:href]
      end
    end
  end

  test "should render component with custom aria label for pagination component" do
    render("components/pagination", {
      aria_label: "some pagination thing",
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
        },
        {
          href: "/page/3",
        },
      ],
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__item", count: 3
    assert_select ".app-c-pagination" do |component|
      assert_equal component.first.attr("aria-label"), "some pagination thing"
    end
  end

  test "should render component with custom aria labels for each item" do
    list_items = [
      {
        href: "/page/1.1",
        aria_label: "Page 1.1",
      },
      {
        href: "/page/2.1",
        current: true,
        aria_label: "Page 2.1",
      },
      {
        href: "/page/3.1",
        aria_label: "Page 3.1",
      },
    ]

    render("components/pagination", {
      items: list_items,
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__prev", count: 0
    assert_select ".govuk-pagination__next", count: 0
    assert_select ".govuk-pagination__item", count: 3
    assert_select(".govuk-pagination__item .govuk-pagination__link") do |elements|
      list_items.each_with_index do |item, index|
        assert_equal elements[index].text, (index + 1).to_s
        assert_equal elements[index].attr("aria-label"), item[:aria_label]
        assert_equal elements[index].attr("href"), item[:href]
      end
    end
  end

  test "should render component with ellipses items" do
    render("components/pagination", {
      items: [
        {
          href: "/page/1",
        },
        {
          ellipses: true,
        },
        {
          href: "/page/20",
        },
        {
          href: "/page/21",
        },
      ],
    })

    assert_select ".app-c-pagination", count: 1
    assert_select ".govuk-pagination__item", count: 4
    assert_select ".govuk-pagination__item.govuk-pagination__item--ellipses", count: 1
  end
end
