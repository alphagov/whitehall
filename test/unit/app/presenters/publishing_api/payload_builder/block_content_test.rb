require "test_helper"

class PublishingApi::PayloadBuilder::BlockContentTest < ActiveSupport::TestCase
  include GovspeakHelper

  setup do
    @item = mock("object")
    @block_content = mock("block_content")
    @item.stubs(:block_content).returns(@block_content)
  end

  test "call returns empty hash when no presenter mapping exists" do
    type_instance = mock("type_instance")
    @item.stubs(:type_instance).returns(type_instance)
    type_instance.stubs(:presenter).with("publishing_api").returns(nil)

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

    assert_equal({}, builder.call)
  end

  test "call builds payload from presenter mapping" do
    type_instance = mock("type_instance")
    @item.stubs(:type_instance).returns(type_instance)
    type_instance.stubs(:presenter).with("publishing_api").returns({
      "body" => :govspeak,
      "start_date" => :rfc3339_date,
    })

    @block_content.stubs(:body).returns("Some govspeak")
    @block_content.stubs(:published_on).returns(Date.new(2025, 12, 11))
    @item.stubs(:images).returns([])
    @item.stubs(:attachments).returns([])

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
    result = builder.call

    assert result.key?("body")
    assert result.key?("start_date")
  end

  test "govspeak returns nil when content is nil" do
    @block_content.stubs(:body).returns(nil)
    @item.stubs(:images).returns([])
    @item.stubs(:attachments).returns([])

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

    assert_nil builder.send(:govspeak, :body)
  end

  test "govspeak converts content to HTML with images and attachments" do
    image = mock("image")
    @block_content.stubs(:body).returns("## Heading\n\nParagraph")
    @item.stubs(:images).returns([image])
    @item.stubs(:attachments).returns([])

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
    builder.expects(:govspeak_to_html).with(
      "## Heading\n\nParagraph",
      images: [image],
      attachments: [],
    ).returns("<h2>Heading</h2><p>Paragraph</p>")

    result = builder.send(:govspeak, :body)
    assert_equal "<h2>Heading</h2><p>Paragraph</p>", result
  end

  test "rfc3339_date converts date to RFC3339 format" do
    date = Date.new(2025, 12, 11)
    @block_content.stubs(:published_on).returns(date)

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
    result = builder.send(:rfc3339_date, :published_on)

    assert_equal date.to_time.rfc3339, result
  end

  test "image returns nil when content is nil or no matching image found" do
    @block_content.stubs(:featured_image).returns(nil)
    @item.stubs(:valid_images).returns([])

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

    assert_nil builder.send(:image, :featured_image)
  end
end
