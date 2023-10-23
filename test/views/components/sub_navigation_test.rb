require "test_helper"

class SubNavigationTest < ActionView::TestCase
  test "should render component" do
    render("components/sub_navigation")

    assert_select ".app-c-sub-navigation", count: 1
  end

  test "should render component with current page" do
    render("components/sub_navigation", {
      items: [
        {
          label: "Nav item 1",
          href: "#",
          current: true,
        },
        {
          label: "Nav item 2",
          href: "#",
        },
        {
          label: "Nav item 3",
          href: "#",
        },
      ],
    })

    assert_select ".app-c-sub-navigation", count: 1
    assert_select ".app-c-sub-navigation__list-item", count: 3
    assert_select ".app-c-sub-navigation__list-item--current", count: 1
    assert_select ".app-c-sub-navigation__list-item--current", text: "Nav item 1"
  end
end
