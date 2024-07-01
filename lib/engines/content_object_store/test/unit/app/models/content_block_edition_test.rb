require "test_helper"

class ContentObjectStore::ContentBlockEditionTest < ActiveSupport::TestCase
  setup do
    ContentObjectStore::ContentBlockEdition.any_instance.stubs(:create_random_id) do
      @new_content_id = SecureRandom.uuid
    end

    @created_at = Time.zone.local(2000, 12, 31, 23, 59, 59).utc
    @updated_at = Time.zone.local(2000, 12, 31, 23, 59, 59).utc
    @details = '{ "some_field": "some_content" }'
    @block_type = "email_address"

    @content_block_edition = build(
      :content_block_edition,
      created_at: @created_at,
      updated_at: @updated_at,
      details: @details,
      block_type: @block_type,
    )
  end

  test "content_block_edition exists with required data" do
    @content_block_edition.save!
    @content_block_edition.reload

    assert_equal @created_at, @content_block_edition.created_at
    assert_equal @updated_at, @content_block_edition.updated_at
    assert_equal @details, @content_block_edition.details
  end

  test "it persists the block type to the document" do
    @content_block_edition.save!
    @content_block_edition.reload

    assert_equal @block_type, @content_block_edition.block_type
  end

  test "it creates a document" do
    @content_block_edition.save!
    @content_block_edition.reload

    assert_not_nil @content_block_edition.document
    assert_equal @content_block_edition.document.content_id, @new_content_id
  end

  test "it adds a content id if a document is provided" do
    @content_block_edition.document = build(:content_block_document, content_id: nil)
    @content_block_edition.save!
    @content_block_edition.reload

    assert_not_nil @content_block_edition.document
    assert_equal @content_block_edition.document.content_id, @new_content_id
  end

  test "it validates the presence of a block_type" do
    @content_block_edition = build(
      :content_block_edition,
      created_at: @created_at,
      updated_at: @updated_at,
      details: @details,
      block_type: nil,
    )

    assert_invalid @content_block_edition
    assert @content_block_edition.errors.full_messages.include?("Block type can't be blank")
  end
end
