# frozen_string_literal: true

require "test_helper"

class Admin::Editions::ImageComponentTest < ViewComponent::TestCase
  setup do
    @edition = build_stubbed(:edition)
    @image = build_stubbed(:image, edition: @edition)
    @image_data = @image.image_data
  end

  test "default fields for persisted images" do
    render_inline(Admin::Editions::ImageComponent.new(image: @image, index: 0))

    assert_selector "h3", text: "Image 1"
    assert_selector "input[name='edition[images_attributes][0][alt_text]'][value='#{@image.alt_text}']"
    assert_selector "textarea[name='edition[images_attributes][0][caption]']"
    assert_selector "input[type='hidden'][name='edition[images_attributes][0][id]'][value='#{@image.id}']", visible: false
    assert_selector "input[type='hidden'][name='edition[images_attributes][0][_destroy]'][value='1']", visible: false
    assert_selector "input[type='checkbox'][name='edition[images_attributes][0][_destroy]'][checked='checked']"
    assert_selector "input[readonly='readonly'][name='markdown_readonly'][value='!!1']"
    assert_selector "img[src='#{@image.url}'][alt='Image 1']"
  end

  test "default fields for new images" do
    image = build(:image, edition: @edition)
    image.stubs(:url).returns(nil)

    render_inline(Admin::Editions::ImageComponent.new(image:, index: 0))

    assert_selector "h3", text: "New image"
    assert_selector "input[type='file'][name='edition[images_attributes][0][image_data_attributes][file]']"
    assert_selector "input[name='edition[images_attributes][0][alt_text]']"
    assert_selector "textarea[name='edition[images_attributes][0][caption]']"
    assert_selector "input[type='hidden'][name='edition[images_attributes][0][id]']", visible: false, count: 0
    assert_selector "input[type='hidden'][name='edition[images_attributes][0][_destroy]']", visible: false, count: 0
    assert_selector "input[type='checkbox'][name='edition[images_attributes][0][_destroy]']", count: 0
    assert_selector "input[readonly='readonly'][name='markdown_readonly'][value='!!1']", count: 0
    assert_selector "img[src='#{image.url}'][alt='Image 1']", count: 0
  end

  test "unchecks the destroy checkbox when checked is false" do
    render_inline(Admin::Editions::ImageComponent.new(image: @image, index: 0, checked: false))

    assert_selector "input[type='checkbox'][name='edition[images_attributes][0][_destroy]'][checked='checked']", count: 0
  end

  test "informs user that the image cannot be used in markdown if `image_disallowed_in_body_text?` returns true" do
    @edition.stubs(:image_disallowed_in_body_text?).returns(true)
    render_inline(Admin::Editions::ImageComponent.new(image: @image, index: 0))

    assert_selector "p", text: "This image is shown automatically, and is not available for use inline in the body."
  end

  test "creates a hidden field for a cache filed and tells the user it has been uploaded when the image data has a file cache present (from a failed save)" do
    render_inline(Admin::Editions::ImageComponent.new(image: @image, index: 0))

    assert_selector "p", text: "minister-of-funk.960x640.jpg already uploaded"
    assert_selector "input[type='hidden'][name='edition[images_attributes][0][image_data_attributes][file_cache]'][value='#{@image_data.file_cache}']", visible: false
  end

  test "does not cache a file when the image data does not have a file cache present" do
    @image_data.stubs(:file_cache).returns(nil)

    render_inline(Admin::Editions::ImageComponent.new(image: @image, index: 0))

    assert_selector "p", text: "minister-of-funk.960x640.jpg already uploaded", count: 0
    assert_selector "input[type='hidden'][name='edition[images_attributes][0][image_data_attributes][file_cache]'][value='#{@image_data.file_cache}']", visible: false, count: 0
  end
end
