require "test_helper"

class ImageBlockTest < ActiveSupport::TestCase
  setup do
    @valid_landing_page_images = [
      build(:image, image_data: build(:landing_page_image_data, file: upload_fixture("landing_page_image.png", "image/png"))),
    ]
    @valid_image_block_config = {
      "type" => "image",
      "image" => {
        "sources" => {
          "desktop" => "[Image: landing_page_image.png]",
          "tablet" => "[Image: landing_page_image.png]",
          "mobile" => "[Image: landing_page_image.png]",
        },
      },
    }
  end

  test "valid when given correct params" do
    subject = LandingPage::ImageBlock.new(@valid_image_block_config, @valid_landing_page_images)
    assert subject.valid?
  end

  test "presents hero blocks to publishing api" do
    subject = LandingPage::ImageBlock.new(@valid_image_block_config, @valid_landing_page_images)
    expected_result = {
      "type" => "image",
      "image" => {
        "alt" => "",
        "sources" => {
          "desktop" => "http://asset-manager/landing_page_desktop_1x",
          "desktop_2x" => "http://asset-manager/landing_page_desktop_2x",
          "tablet" => "http://asset-manager/landing_page_tablet_1x",
          "tablet_2x" => "http://asset-manager/landing_page_tablet_2x",
          "mobile" => "http://asset-manager/landing_page_mobile_1x",
          "mobile_2x" => "http://asset-manager/landing_page_mobile_2x",
        },
      },
    }
    assert_equal(expected_result, subject.present_for_publishing_api)
  end

  test "invalid when missing images" do
    subject = LandingPage::ImageBlock.new(@valid_image_block_config.except("image"), @valid_landing_page_images)
    assert subject.invalid?
    assert_equal [
      "Desktop image can't be blank",
      "Tablet image can't be blank",
      "Mobile image can't be blank",
    ], subject.errors.to_a
  end

  test "invalid when image expressions are not found" do
    no_images = []
    subject = LandingPage::ImageBlock.new(@valid_image_block_config, no_images)
    assert subject.invalid?
    assert_equal [
      "Desktop image can't be blank",
      "Tablet image can't be blank",
      "Mobile image can't be blank",
    ], subject.errors.to_a
  end
end
