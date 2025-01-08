require "test_helper"

class FeaturedBlockTest < ActiveSupport::TestCase
  setup do
    @valid_featured_images = [
      build(:image, image_data: build(:landing_page_image_data, file: upload_fixture("landing_page_image.png", "image/png"))),
    ]
    @valid_featured_block_config = {
      "type" => "featured",
      "image" => {
        "alt" => "some alt text",
        "sources" => {
          "desktop" => "[Image: landing_page_image.png]",
          "tablet" => "[Image: landing_page_image.png]",
          "mobile" => "[Image: landing_page_image.png]",
        },
      },
      "featured_content" => { "blocks" => [{ "type" => "some-block-type" }] },
    }
  end

  test "valid when given correct params" do
    subject = LandingPage::FeaturedBlock.new(@valid_featured_block_config, @valid_featured_images)
    assert subject.valid?
  end

  test "presents featured blocks to publishing api" do
    subject = LandingPage::FeaturedBlock.new(@valid_featured_block_config, @valid_featured_images)
    expected_result = {
      "type" => "featured",
      "image" => {
        "alt" => "some alt text",
        "sources" => {
          "desktop" => "http://asset-manager/landing_page_desktop_1x",
          "desktop_2x" => "http://asset-manager/landing_page_desktop_2x",
          "tablet" => "http://asset-manager/landing_page_tablet_1x",
          "tablet_2x" => "http://asset-manager/landing_page_tablet_2x",
          "mobile" => "http://asset-manager/landing_page_mobile_1x",
          "mobile_2x" => "http://asset-manager/landing_page_mobile_2x",
        },
      },
      "featured_content" => {
        "blocks" => [{ "type" => "some-block-type" }],
      },
    }
    assert_equal(expected_result, subject.present_for_publishing_api)
  end

  test "invalid when missing images" do
    subject = LandingPage::FeaturedBlock.new(@valid_featured_block_config.except("image"), @valid_featured_images)
    assert subject.invalid?
    assert_equal [
      "Desktop image cannot be blank",
      "Tablet image cannot be blank",
      "Mobile image cannot be blank",
    ], subject.errors.to_a
  end

  test "invalid when image expressions are not found" do
    no_images = []
    subject = LandingPage::FeaturedBlock.new(@valid_featured_block_config, no_images)
    assert subject.invalid?
    assert_equal [
      "Desktop image cannot be blank",
      "Tablet image cannot be blank",
      "Mobile image cannot be blank",
    ], subject.errors.to_a
  end

  test "valid when missing featured content blocks" do
    subject = LandingPage::FeaturedBlock.new(
      @valid_featured_block_config.except("featured_content"),
      @valid_featured_images,
    )
    assert subject.valid?
  end

  test "invalid when featured content blocks are invalid" do
    invalid_blocks_config = [{ "invalid" => "because I do not have a type" }]
    subject = LandingPage::FeaturedBlock.new(
      @valid_featured_block_config.merge("featured_content" => { "blocks" => invalid_blocks_config }),
      @valid_featured_images,
    )
    assert subject.invalid?
    assert_equal ["Type cannot be blank"], subject.errors.to_a
  end
end
