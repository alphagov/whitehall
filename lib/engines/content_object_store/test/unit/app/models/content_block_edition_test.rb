require "test_helper"

class ContentObjectStore::ContentBlockEditionTest < ActiveSupport::TestCase
  setup do
    @new_content_id = SecureRandom.uuid
    ContentObjectStore::ContentBlockEdition.any_instance.stubs(:create_random_id).returns(@new_content_id)

    @created_at = Time.zone.local(2000, 12, 31, 23, 59, 59).utc
    @updated_at = Time.zone.local(2000, 12, 31, 23, 59, 59).utc
    @details = '{ "some_field": "some_content" }'
    @document_title = "Document title"

    @content_block_edition = build(
      :content_block_edition,
      :email_address,
      created_at: @created_at,
      updated_at: @updated_at,
      details: @details,
      document_title: @document_title,
      content_block_document: nil,
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
    document = @content_block_edition.document

    assert_equal document.block_type, @content_block_edition.block_type
  end

  test "it persists the title to the document" do
    @content_block_edition.save!
    @content_block_edition.reload
    document = @content_block_edition.document

    assert_equal document.title, @content_block_edition.title
  end

  test "it creates a document" do
    @content_block_edition.save!
    @content_block_edition.reload

    assert_not_nil @content_block_edition.document
    assert_equal @content_block_edition.document.content_id, @new_content_id
  end

  test "it adds a content id if a document is provided" do
    @content_block_edition.document = build(:content_block_document, :email_address, content_id: nil)
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

  test "it does not expect a block_type on update requests" do
    @content_block_edition = create(
      :content_block_edition,
      :email_address
    )

    # We omitt the block_type here to simulate an update request
    @content_block_edition.update(details: "{ bar: 1 }")

    assert @content_block_edition.details, "{ bar: 1 }"
  end
end
