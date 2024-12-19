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
    subject = LandingPages::CompoundBlock.new(
      @valid_block_config,
      EMPTY_IMAGES,
      "compound_block_content",
      @valid_content_blocks,
    )
    assert subject.valid?
  end

  test "presents compound blocks to publishing api" do
    subject = LandingPages::CompoundBlock.new(
      @valid_block_config,
      EMPTY_IMAGES,
      "compound_block_content",
      @valid_content_blocks,
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
    subject = LandingPages::CompoundBlock.new(
      @valid_block_config,
      EMPTY_IMAGES,
      "compound_block_content",
      nil,
    )
    assert subject.valid?
  end

  test "presents without missing content blocks" do
    subject = LandingPages::CompoundBlock.new(
      @valid_block_config.except("compound_block_content"),
      EMPTY_IMAGES,
      "compound_block_content",
      nil,
    )
    assert_equal({ "type" => "some-compound-block" }, subject.present_for_publishing_api)
  end

  test "invalid when content blocks are invalid" do
    invalid_blocks_config = [{ "invalid" => "because I do not have a type" }]
    subject = LandingPages::CompoundBlock.new(
      @valid_block_config,
      EMPTY_IMAGES,
      "compound_block_content",
      invalid_blocks_config,
    )
    assert subject.invalid?
    assert_equal ["Type can't be blank"], subject.errors.to_a
  end
end
