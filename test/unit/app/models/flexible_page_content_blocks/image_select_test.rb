require "test_helper"
class FlexiblePageContentBlocks::ImageSelectTest < ActiveSupport::TestCase
  test "it allows the content to be an empty string" do
    validator = FlexiblePageContentBlocks::ImageSelect.new.json_schema_validator
    assert validator.call("")
  end

  test "it validates that the content is a string that can be cast to an integer" do
    validator = FlexiblePageContentBlocks::ImageSelect.new.json_schema_validator
    assert_not validator.call("abc")
  end

  test "it loads the correct image and presents the image attributes" do
    images = create_list(:image, 3)
    page = FlexiblePage.new
    page.images = images
    FlexiblePageContentBlocks::Context.create(page, nil)
    payload = FlexiblePageContentBlocks::ImageSelect.new.publishing_api_payload(images[1].id)

    assert_equal({
      src: images[1].url,
      caption: images[1].caption,
      alt_text: images[1].alt_text,
    }, payload)
  end

  test "does not have a publishing api payload if no image is selected" do
    page = FlexiblePage.new
    FlexiblePageContentBlocks::Context.create(page, nil)
    payload = FlexiblePageContentBlocks::ImageSelect.new.publishing_api_payload("")

    assert_nil payload
  end
end

class FlexiblePageContentBlocks::ImageSelectRenderingTest < ActionView::TestCase
  test "it renders a select with the selected image filename" do
    @schema = {
      "type" => "object",
      "properties" => {
        "test_attribute" => {
          "type" => "string",
          "title" => "Test attribute",
          "description" => "A test attribute",
          "format" => "image_select",
        },
      },
    }

    @page = FlexiblePage.new
    @page.images = create_list(:image, 3)
    FlexiblePageContentBlocks::Context.create(@page, view)
    @page.flexible_page_content = { "test_attribute" => @page.images.last.id.to_s }
    @block = FlexiblePageContentBlocks::ImageSelect.new

    path = %w[test_attribute]
    render html: @block.render(
      @schema["properties"]["test_attribute"],
      @page.flexible_page_content["test_attribute"],
      path,
    )

    assert_dom "select[name=?]", "edition[flexible_page_content][#{path.join('][')}]"
    assert_dom "option[selected]", text: @page.images.last.filename
    @page.images.each do |image|
      assert_dom "option", text: image.filename
    end
  end
end
