require "test_helper"

class ContentBlockManager::ContentBlockDocumentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  it "exists with required data" do
    content_block_document = create(
      :content_block_document,
      :email_address,
      content_id: "52084b2d-4a52-4e69-ba91-3052b07c7eb6",
      title: "Title",
      created_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
      updated_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
    )

    assert_equal "52084b2d-4a52-4e69-ba91-3052b07c7eb6", content_block_document.content_id
    assert_equal "Title", content_block_document.title
    assert_equal "email_address", content_block_document.block_type
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_document.created_at
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_document.updated_at
  end

  it "does not allow the block type to be changed" do
    content_block_document = create(:content_block_document, :email_address)

    assert_raise ActiveRecord::ReadonlyAttributeError do
      content_block_document.update(block_type: "something_else")
    end
  end

  it "can store the id of the latest edition" do
    content_block_document = create(:content_block_document, :email_address)
    content_block_document.update!(latest_edition_id: 1)
    assert content_block_document.reload.latest_edition_id, 1
  end

  it "can store the id of the live edition" do
    content_block_document = create(:content_block_document, :email_address)
    content_block_document.update!(live_edition_id: 1)
    assert content_block_document.reload.live_edition_id, 1
  end

  it "gets its version history from its editions" do
    document = create(:content_block_document, :email_address)
    edition = create(
      :content_block_edition,
      document:,
    )
    document.update!(editions: [edition])

    assert_equal document.versions.first.item.id, edition.id
  end

  describe "embed_code" do
    it "returns embed code for the document" do
      uuid = SecureRandom.uuid
      document = create(:content_block_document, :email_address, content_id: uuid)

      assert_equal document.embed_code, "{{embed:content_block_email_address:#{uuid}}}"
    end
  end

  describe "latest_edition" do
    it "returns the latest edition" do
      document = create(:content_block_document, :email_address)
      _first_edition = create(:content_block_edition, document:)
      second_edition = create(:content_block_edition, document:)

      assert_equal second_edition, document.latest_edition
    end
  end

  describe ".live" do
    it "only returns documents with a latest edition" do
      document_with_latest_edition = create(:content_block_document, :email_address)
      latest_edition = create(:content_block_edition, document: document_with_latest_edition)
      document_with_latest_edition.latest_edition_id = latest_edition.id
      document_with_latest_edition.save!

      create(:content_block_document, :email_address, latest_edition_id: nil)

      assert_equal [document_with_latest_edition], ContentBlockManager::ContentBlock::Document.live
    end
  end
end
