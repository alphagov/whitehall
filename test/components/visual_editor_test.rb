require "component_test_helper"

class VisualeditorComponentTest < ComponentTestCase
  def component_name
    "visual_editor"
  end

  test "errors when no parameters given" do
    assert_raises do
      render_component({})
    end
  end

  test "renders the basic component" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      rows: 10,
      right_to_left: false,
      data_attributes: {},
      hidden_field_name: "object[name]",
    })

    assert_select "div[data-module='visual-editor']"
  end
end
