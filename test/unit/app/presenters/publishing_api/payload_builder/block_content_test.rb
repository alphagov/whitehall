require "test_helper"

class PublishingApi::PayloadBuilder::BlockContentTest < ActiveSupport::TestCase
  include GovspeakHelper
  extend Minitest::Spec::DSL

  setup do
    @item = mock("object")
    @block_content = mock("block_content")
    @item.stubs(:block_content).returns(@block_content)
  end

  test "call builds payload from presenter mapping" do
    type_instance = mock("type_instance")
    @item.stubs(:type_instance).returns(type_instance)
    type_instance.stubs(:presenter).with("publishing_api").returns({
      "details" => {
        "body" => :govspeak,
        "published_on" => :rfc3339_date,
      },
    })

    @block_content.stubs(:body).returns("Some govspeak")
    @block_content.stubs(:published_on).returns(Date.new(2025, 12, 11))
    @item.stubs(:images).returns([])
    @item.stubs(:attachments).returns([])

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
    result = builder.call

    assert result.key?(:body)
    assert result.key?(:published_on)
  end

  test "call skips nil values in payload" do
    type_instance = mock("type_instance")
    @item.stubs(:type_instance).returns(type_instance)
    @item.stubs(:placeholder_image_url).returns(nil)

    type_instance.stubs(:presenter).with("publishing_api").returns({
      "details" => {
        "body_attribute" => :govspeak,
        "date_attribute" => :rfc3339_date,
        "string_attribute" => :raw,
      },
    })
    @block_content.stubs(:body_attribute).returns(nil)
    @block_content.stubs(:date_attribute).returns(nil)
    @block_content.stubs(:string_attribute).returns(nil)

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
    result = builder.call

    assert_not result.key?(:body_attribute)
    assert_not result.key?(:date_attribute)
    assert_not result.key?(:string_attribute)
  end

  context "raw payload builder" do
    test "raw sends the string content as-is" do
      string_content = "foo"
      @block_content.stubs(:string_chunk).returns(string_content)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:raw, :string_chunk)

      assert_equal string_content, result
    end

    test "raw sends the array content as-is" do
      array_content = [{ foo: "foo" }, { bar: "bar" }]
      @block_content.stubs(:array_chunk).returns(array_content)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:raw, :array_chunk)

      assert_equal array_content, result
    end
  end

  context "govspeak payload builder" do
    test "govspeak returns nil when content is nil" do
      @item.stubs(:block_content).returns(nil)
      @item.stubs(:images).returns([])
      @item.stubs(:attachments).returns([])

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_nil builder.send(:govspeak, :body_attribute)
    end

    test "govspeak returns nil when content for attribute is nil" do
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
  end

  context "rfc3339_date payload builder" do
    test "rfc3339_date converts date to RFC3339 format" do
      date = Date.new(2025, 12, 11)
      @block_content.stubs(:published_on).returns(date)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:rfc3339_date, :published_on)

      assert_equal date.to_time.rfc3339, result
    end

    test "rfc3339_date returns nil if content is nil" do
      @item.stubs(:block_content).returns(nil)
      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_nil builder.send(:rfc3339_date, :date_attribute)
    end

    test "rfc3339_date returns nil if content for attribute is nil" do
      @block_content.stubs(:published_on).returns(nil)
      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_nil builder.send(:rfc3339_date, :published_on)
    end
  end

  context "social_media_links builder" do
    test "social_media_links returns empty array when block_content is nil" do
      @item.stubs(:block_content).returns(nil)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_equal [], builder.send(:social_media_links, :some_attribute)
    end

    test "social_media_links returns empty array when no links have been provided" do
      @block_content.stubs(:some_attribute).returns(nil)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_equal [], builder.send(:social_media_links, :some_attribute)
    end

    test "social_media_links returns array of social media links" do
      value_of_links = [{ "social_media_service_name" => "twitter", "url" => "https://example.com" }]
      @block_content.stubs(:some_attribute).returns(value_of_links)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      expected_payload = [
        {
          title: value_of_links.first["social_media_service_name"],
          service_type: value_of_links.first["social_media_service_name"].parameterize,
          href: value_of_links.first["url"],
        },
      ]
      assert_equal expected_payload, builder.send(:social_media_links, :some_attribute)
    end
  end
end
