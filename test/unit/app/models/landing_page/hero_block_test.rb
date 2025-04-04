require "test_helper"

class HeroBlockTest < ActiveSupport::TestCase
  setup do
    @valid_hero_block_images = [
      build(:image, image_data: build(:hero_image_data, image_kind: "hero_desktop", file: upload_fixture("hero_image_desktop_2x.png", "image/png"))),
      build(:image, image_data: build(:hero_image_data, image_kind: "hero_tablet", file: upload_fixture("hero_image_tablet_2x.png", "image/png"))),
      build(:image, image_data: build(:hero_image_data, image_kind: "hero_mobile", file: upload_fixture("hero_image_mobile_2x.png", "image/png"))),
    ]
    @valid_hero_content_blocks = [{ "type" => "some-block-type" }]
    @valid_hero_block_config = {
      "type" => "hero",
      "image" => {
        "sources" => {
          "desktop" => "[Image: hero_image_desktop_2x.png]",
          "tablet" => "[Image: hero_image_tablet_2x.png]",
          "mobile" => "[Image: hero_image_mobile_2x.png]",
        },
      },
      "hero_content" => { "blocks" => @valid_hero_content_blocks },
    }
  end

  test "valid when given correct params" do
    subject = LandingPage::HeroBlock.new(@valid_hero_block_config, @valid_hero_block_images)
    assert subject.valid?
  end

  test "presents hero blocks to publishing api" do
    subject = LandingPage::HeroBlock.new(@valid_hero_block_config, @valid_hero_block_images)
    expected_result = {
      "type" => "hero",
      "image" => {
        "alt" => "",
        "sources" => {
          "desktop" => "http://asset-manager/hero_desktop_1x",
          "desktop_2x" => "http://asset-manager/hero_desktop_2x",
          "tablet" => "http://asset-manager/hero_tablet_1x",
          "tablet_2x" => "http://asset-manager/hero_tablet_2x",
          "mobile" => "http://asset-manager/hero_mobile_1x",
          "mobile_2x" => "http://asset-manager/hero_mobile_2x",
        },
      },
      "hero_content" => {
        "blocks" => [{ "type" => "some-block-type" }],
      },
    }
    assert_equal(expected_result, subject.present_for_publishing_api)
  end

  test "invalid when missing images" do
    subject = LandingPage::HeroBlock.new(@valid_hero_block_config.except("image"), @valid_hero_block_images)
    assert subject.invalid?
    assert_equal [
      "Desktop image cannot be blank",
      "Tablet image cannot be blank",
      "Mobile image cannot be blank",
    ], subject.errors.to_a
  end

  test "invalid when image expressions are not found" do
    no_images = []
    subject = LandingPage::HeroBlock.new(@valid_hero_block_config, no_images)
    assert subject.invalid?
    assert_equal [
      "Desktop image cannot be blank",
      "Tablet image cannot be blank",
      "Mobile image cannot be blank",
    ], subject.errors.to_a
  end

  test "valid when missing hero content blocks" do
    subject = LandingPage::HeroBlock.new(@valid_hero_block_config.except("hero_content"), @valid_hero_block_images)
    subject.valid?
  end

  test "invalid when hero content blocks are invalid" do
    invalid_blocks_config = [{ "invalid" => "because I do not have a type" }]
    subject = LandingPage::HeroBlock.new(
      @valid_hero_block_config.merge("hero_content" => { "blocks" => invalid_blocks_config }),
      @valid_hero_block_images,
    )
    assert subject.invalid?
    assert_equal ["Type cannot be blank"], subject.errors.to_a
  end
end
