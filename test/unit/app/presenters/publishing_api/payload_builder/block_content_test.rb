require "test_helper"

class PublishingApi::PayloadBuilder::BlockContentTest < ActiveSupport::TestCase
  include GovspeakHelper
  extend Minitest::Spec::DSL

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
      "published_on" => :rfc3339_date,
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
    @item.stubs(:valid_lead_images).returns([])
    @item.stubs(:default_lead_image).returns(nil)
    @item.stubs(:placeholder_image_url).returns(nil)

    type_instance.stubs(:presenter).with("publishing_api").returns({
      "body_attribute" => :govspeak,
      "date_attribute" => :rfc3339_date,
      "image_attribute" => :image,
      "lead_image_attribute" => :lead_image,
      "string_attribute" => :raw,
    })
    @block_content.stubs(:body_attribute).returns(nil)
    @block_content.stubs(:date_attribute).returns(nil)
    @block_content.stubs(:image_attribute).returns(nil)
    @block_content.stubs(:lead_image_attribute).returns(nil)
    @block_content.stubs(:string_attribute).returns(nil)

    builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
    result = builder.call

    assert_not result.key?(:body_attribute)
    assert_not result.key?(:date_attribute)
    assert_not result.key?(:image_attribute)
    assert result.key?(:lead_image_attribute) # because the behaviour of this block is special - will always return a value
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

  context "image payload builder" do
    test "image returns nil when content is nil" do
      @item.stubs(:block_content).returns(nil)
      @item.stubs(:valid_images).returns([])

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_nil builder.send(:image, :image_attribute)
    end

    test "image returns nil when content for attribute is nil" do
      @block_content.stubs(:featured_image).returns(nil)
      @item.stubs(:valid_images).returns([])

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_nil builder.send(:image, :featured_image)
    end

    test "image returns nil when no matching image found" do
      featured_image = create(:image)
      random_valid_image = create(:image)
      @block_content.stubs(:featured_image).returns(featured_image.image_data.id)
      @item.stubs(:valid_images).returns([random_valid_image])

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_nil builder.send(:image, :featured_image)
    end

    test "image returns nil if selected image's assets are not ready" do
      images = create_list(:image, 2)
      images[1].image_data.assets = []
      images[1].image_data.save!
      @block_content.stubs(:featured_image).returns(images[1].image_data.id)
      @item.stubs(:valid_images).returns(images)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      assert_nil builder.send(:image, :featured_image)
    end

    test "it does not send the caption if nil" do
      image = create(:image, caption: nil)
      @block_content.stubs(:featured_image).returns(image.image_data.id)
      @item.stubs(:valid_images).returns([image])

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:image, :featured_image)

      assert_equal({ url: image.url }, result)
    end

    test "it loads the correct image and presents the image attributes" do
      images = [create(:image), create(:image, caption: "Example caption")]
      @block_content.stubs(:featured_image).returns(images[1].image_data.id)
      @item.stubs(:valid_images).returns(images)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:image, :featured_image)

      payload = {
        url: images[1].url,
        caption: images[1].caption,
      }
      assert_equal payload, result
    end
  end

  context "lead_image payload builder" do
    test "lead image sends the custom lead image payload to publishing-api" do
      images = [create(:image), create(:image, caption: "Example caption")]
      @item.stubs(:valid_lead_images).returns(images)
      @block_content.stubs(:image).returns(images[1].image_data.id)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:lead_image, :image)

      payload = {
        high_resolution_url: images[1].image_data.url(:s960),
        url: images[1].image_data&.url(:s300),
        caption: images[1].caption,
      }
      assert_equal payload, result
    end

    test "lead image does not send the the caption if nil" do
      image = create(:image, caption: nil)
      @item.stubs(:valid_lead_images).returns([image])
      @block_content.stubs(:image).returns(image.image_data.id)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:lead_image, :image)

      payload = {
        high_resolution_url: image.image_data.url(:s960),
        url: image.image_data&.url(:s300),
      }
      assert_equal payload, result
    end

    test "lead image sends the default lead image payload if content is nil" do
      default_lead_image = build(:featured_image_data)
      @item.stubs(:valid_lead_images).returns([])
      @item.stubs(:default_lead_image).returns(default_lead_image)
      @item.stubs(:block_content).returns(nil)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:lead_image, :lead_image_attribute)

      payload = {
        high_resolution_url: default_lead_image.url(:s960),
        url: default_lead_image.url(:s300),
      }
      assert_equal payload, result
    end

    test "lead image sends the default lead image payload if content for image attribute is nil" do
      default_lead_image = build(:featured_image_data)
      @item.stubs(:valid_lead_images).returns([])
      @item.stubs(:default_lead_image).returns(default_lead_image)
      @block_content.stubs(:image).returns(nil)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:lead_image, :image)

      payload = {
        high_resolution_url: default_lead_image.url(:s960),
        url: default_lead_image.url(:s300),
      }
      assert_equal payload, result
    end

    test "lead image sends the placeholder image url if selected image's assets are missing" do
      images = create_list(:image, 3)
      images[1].image_data.assets = []
      images[1].image_data.save!
      placeholder_image_url = "https://assets.publishing.service.gov.uk/media/_ID_/placeholder.jpg"
      @item.stubs(:valid_lead_images).returns(images)
      @item.stubs(:placeholder_image_url).returns(placeholder_image_url)
      @block_content.stubs(:image).returns(images[1].image_data.id)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:lead_image, :image)

      payload = {
        high_resolution_url: placeholder_image_url,
        url: placeholder_image_url,
      }
      assert_equal payload, result
    end

    test "lead image sends the placeholder image url if there is no custom image and default lead image's assets are missing" do
      default_lead_image = build(:featured_image_data)
      default_lead_image.assets = []
      default_lead_image.save!
      placeholder_image_url = "https://assets.publishing.service.gov.uk/media/_ID_/placeholder.jpg"
      @item.stubs(:valid_lead_images).returns([])
      @item.stubs(:default_lead_image).returns(default_lead_image)
      @item.stubs(:placeholder_image_url).returns(placeholder_image_url)
      @block_content.stubs(:image).returns(nil)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:lead_image, :image)

      payload = {
        high_resolution_url: placeholder_image_url,
        url: placeholder_image_url,
      }
      assert_equal payload, result
    end

    test "lead image sends the placeholder image url if custom lead and organisation default images are missing" do
      placeholder_image_url = "https://assets.publishing.service.gov.uk/media/_ID_/placeholder.jpg"
      @item.stubs(:valid_lead_images).returns([])
      @item.stubs(:default_lead_image).returns(nil)
      @item.stubs(:placeholder_image_url).returns(placeholder_image_url)
      @block_content.stubs(:image).returns(nil)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)
      result = builder.send(:lead_image, :image)

      payload = {
        high_resolution_url: placeholder_image_url,
        url: placeholder_image_url,
      }
      assert_equal payload, result
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

    test "social_media_links returns array of social media links using config options" do
      form = {
        "fields" => {
          "some_attribute" => {
            "fields" => {
              "social_media_service_id" => {
                "options" => [
                  { "label" => "Twitter", "value" => "twitter" },
                  { "label" => "Facebook", "value" => "facebook" },
                ],
              },
            },
          },
        },
      }
      type_instance = mock("type_instance")
      @item.stubs(:type_instance).returns(type_instance)
      type_instance.stubs(:form).with("documents").returns(form)

      value_of_links = [{ "social_media_service_id" => "twitter", "url" => "https://twitter.com/govuk" }]
      @block_content.stubs(:some_attribute).returns(value_of_links)

      builder = PublishingApi::PayloadBuilder::BlockContent.new(@item)

      expected_payload = [
        {
          title: "Twitter",
          service_type: "twitter",
          href: "https://twitter.com/govuk",
        },
      ]
      assert_equal expected_payload, builder.send(:social_media_links, :some_attribute)
    end
  end
end
