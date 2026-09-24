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
      filename: "filename",
      type: "type",
      width: 960,
      height: 640,
      image: create(:image),
      edition: create(:edition),
    })

    assert_select ".app-c-image-cropper"
  end

  test "renders multiple cropping outlines data attribute as false by default" do
    render_component({
      name: "name",
      filename: "filename",
      type: "type",
      width: 960,
      height: 640,
      image: create(:image),
      edition: create(:edition),
    })

    assert_select ".app-c-image-cropper[data-multi-crop-outlines='false']"
  end

  test "renders multiple cropping outlines data attribute as true when enabled" do
    render_component({
      name: "name",
      filename: "filename",
      type: "type",
      width: 960,
      height: 640,
      multi_crop_outlines: true,
      image: create(:image),
      edition: create(:edition),
    })

    assert_select ".app-c-image-cropper[data-multi-crop-outlines='true']"
  end
end
