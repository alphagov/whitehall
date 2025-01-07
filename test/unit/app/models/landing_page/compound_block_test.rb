require "test_helper"

class CompoundBlockTest < ActiveSupport::TestCase
  EMPTY_IMAGES = [].freeze

  setup do
    @valid_content_blocks = [{ "type" => "some-block-type" }]
    @valid_block_config = {
      "type" => "some-compound-block",
      "compound_block_content" => { "blocks" => @valid_content_blocks },
    }
  end

  test "valid when given correct params" do
    subject = LandingPage::CompoundBlock.new(
      @valid_block_config,
      EMPTY_IMAGES,
      "compound_block_content",
    )
    assert subject.valid?
  end

  test "presents compound blocks to publishing api" do
    subject = LandingPage::CompoundBlock.new(
      @valid_block_config,
      EMPTY_IMAGES,
      "compound_block_content",
    )
    expected_result = {
      "type" => "some-compound-block",
      "compound_block_content" => {
        "blocks" => [{ "type" => "some-block-type" }],
      },
    }
    assert_equal(expected_result, subject.present_for_publishing_api)
  end

  test "valid when missing content blocks" do
    subject = LandingPage::CompoundBlock.new(
      @valid_block_config.except("compound_block_content"),
      EMPTY_IMAGES,
      "compound_block_content",
    )
    assert subject.valid?
  end

  test "presents without missing content blocks" do
    subject = LandingPage::CompoundBlock.new(
      @valid_block_config.except("compound_block_content"),
      EMPTY_IMAGES,
      "compound_block_content",
    )
    assert_equal({ "type" => "some-compound-block" }, subject.present_for_publishing_api)
  end

  test "invalid when content blocks are invalid" do
    invalid_blocks_config = [{ "invalid" => "because I do not have a type" }]
    subject = LandingPage::CompoundBlock.new(
      @valid_block_config.merge("compound_block_content" => { "blocks" => invalid_blocks_config }),
      EMPTY_IMAGES,
      "compound_block_content",
    )
    assert subject.invalid?
    assert_equal ["Type cannot be blank"], subject.errors.to_a
  end
end
