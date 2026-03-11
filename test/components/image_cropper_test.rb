require "component_test_helper"

class ImagecropperComponentTest < ComponentTestCase
  def component_name
    "image_cropper"
  end

  test "errors when no parameters given" do
    assert_raises do
      render_component({})
    end
  end

  test "renders the basic component" do
    render_component({
      name: "name",
      src: "src",
      filename: "filename",
      type: "type",
      width: 960,
      height: 640,
    })

    assert_select ".app-c-image-cropper"
  end
end
