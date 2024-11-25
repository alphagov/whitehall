require "test_helper"

class HeroBlockTest < ActiveSupport::TestCase
  StubImage = Data.define(:filename) do
    def url(version)
      "https://example.com/#{version}/#{filename}"
    end
  end

  setup do
    @valid_hero_block_images = [
      StubImage.new("desktop.jpg"),
      StubImage.new("tablet.jpg"),
      StubImage.new("mobile.jpg"),
    ]
    @valid_hero_block_config = {
      "type" => "hero",
      "image" => {
        "sources" => {
          "desktop" => "[Image: desktop.jpg]",
          "tablet" => "[Image: tablet.jpg]",
          "mobile" => "[Image: mobile.jpg]",
        },
      },
      "hero_content" => {
        "blocks" => [{ "type" => "some-block-type" }],
      },
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
          "desktop" => "https://example.com/hero_desktop_1x/desktop.jpg",
          "desktop_2x" => "https://example.com/hero_desktop_2x/desktop.jpg",
          "tablet" => "https://example.com/hero_tablet_1x/tablet.jpg",
          "tablet_2x" => "https://example.com/hero_tablet_2x/tablet.jpg",
          "mobile" => "https://example.com/hero_mobile_1x/mobile.jpg",
          "mobile_2x" => "https://example.com/hero_mobile_2x/mobile.jpg",
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
      "Desktop image can't be blank",
      "Tablet image can't be blank",
      "Mobile image can't be blank",
    ], subject.errors.to_a
  end

  test "invalid when image expressions are not found" do
    no_images = []
    subject = LandingPage::HeroBlock.new(@valid_hero_block_config, no_images)
    assert subject.invalid?
    assert_equal [
      "Desktop image can't be blank",
      "Tablet image can't be blank",
      "Mobile image can't be blank",
    ], subject.errors.to_a
  end

  test "invalid when missing hero content blocks" do
    subject = LandingPage::HeroBlock.new(@valid_hero_block_config.except("hero_content"), @valid_hero_block_images)
    assert subject.invalid?
    assert_equal ["Hero content blocks can't be blank"], subject.errors.to_a
  end
end
