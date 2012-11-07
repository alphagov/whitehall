require "test_helper"

class LeadImagePresenterHelperTest < ActiveSupport::TestCase
  setup do
    @presenter = stub("Target", images:[]).extend(LeadImagePresenterHelper)
  end

  test "should use placeholder image if none had been uploaded" do
    assert_match /placeholder.jpg/, @presenter.lead_image_path
    assert_equal 'placeholder', @presenter.lead_image_alt_text
  end

  test "should use first image with version :s300 if an image is present" do
    image = stub("Image", url: "url", alt_text: "alt_text")
    @presenter.stubs(images: [image])
    assert_equal 'url', @presenter.lead_image_path
    assert_equal 'alt_text', @presenter.lead_image_alt_text
  end
end
