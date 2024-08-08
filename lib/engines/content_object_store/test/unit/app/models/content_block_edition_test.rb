require "test_helper"

class ContentObjectStore::ContentBlockEditionTest < ActiveSupport::TestCase
  setup do
    @new_content_id = SecureRandom.uuid
    ContentObjectStore::ContentBlock::Edition.any_instance.stubs(:create_random_id).returns(@new_content_id)

    @created_at = Time.zone.local(2000, 12, 31, 23, 59, 59).utc
    @updated_at = Time.zone.local(2000, 12, 31, 23, 59, 59).utc
    @details = { "some_field" => "some_content" }
    @title = "Document title"
    @creator = create(:user)
    @organisation = create(:organisation)

    @content_block_edition = ContentObjectStore::ContentBlock::Edition.new(
      created_at: @created_at,
      updated_at: @updated_at,
      details: @details,
      document_attributes: {
        block_type: "email_address",
        title: @title,
      },
      creator: @creator,
      organisation_id: @organisation.id.to_s,
    )
    @content_block_edition.stubs(:schema).returns(build(:content_block_schema))
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

  test "it validates the presence of a document block_type" do
    @content_block_edition = build(
      :content_block_edition,
      created_at: @created_at,
      updated_at: @updated_at,
      details: @details,
      document_attributes: {
        block_type: nil,
      },
      organisation_id: @organisation.id.to_s,
    )

    assert_invalid @content_block_edition
    assert @content_block_edition.errors.full_messages.include?("Document block type can't be blank")
  end

  test "it validates the presence of a document title" do
    content_block_edition = build(
      :content_block_edition,
      created_at: @created_at,
      updated_at: @updated_at,
      details: @details,
      document_attributes: {
        title: nil,
      },
      organisation_id: @organisation.id.to_s,
    )

    assert_invalid content_block_edition
    assert content_block_edition.errors.full_messages.include?("Title can't be blank")
  end

  test "it adds a creator and first edition author for new records" do
    @content_block_edition.save!
    @content_block_edition.reload
    assert_equal @content_block_edition.creator, @content_block_edition.edition_authors.first.user
  end

  test "#creator= raises an exception if called for a persisted record" do
    @content_block_edition.save!
    assert_raise RuntimeError do
      @content_block_edition.creator = create(:user)
    end
  end
end
