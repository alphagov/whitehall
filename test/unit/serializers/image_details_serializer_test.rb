require "test_helper"
require 'active_model_serializers'

class ImageDetailsSerializerTest < ActiveSupport::TestCase
  def stubbed_item
    stub(
      lead_image_path: '/lead_image.png',
      lead_image_alt_text: 'An image',
      lead_image_caption: 'An image caption'
    )
  end

  def serializer
    ImageDetailsSerializer.new(stubbed_item)
  end

  test "it includes the URL for the image" do
    host = "http://www.somehost.com"
    Whitehall.stub(:public_asset_host, host) do
      assert_equal serializer.url, "#{host}/lead_image.png"
    end
  end

  test "it includes the alt test of the image" do
    assert_equal serializer.alt_text, stubbed_item.lead_image_alt_text
  end

  test "it includes the caption of the image" do
    assert_equal serializer.caption, stubbed_item.lead_image_caption
  end
end
