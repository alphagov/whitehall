require "component_test_helper"

class ChildOfBannerComponentTest < ComponentTestCase
  def component_name
    "child_of_banner"
  end

  test "renders the basic component" do
    render_component({
      title: "title",
      edition_type: "type",
    })

    assert_select ".app-c-child-of-banner"
    assert_select ".app-c-child-of-banner__part-of", text: "Child of type"
    assert_select ".app-c-child-of-banner__title", text: "title"
  end

  test "renders a link if path has been provided" do
    render_component({
      title: "title",
      edition_type: "type",
      path: "/example-path",
    })

    assert_select ".app-c-child-of-banner__link[href='/example-path']", text: "Edit child pages"
  end
end
