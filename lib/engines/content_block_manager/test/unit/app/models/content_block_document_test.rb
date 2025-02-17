require "test_helper"

class ContentBlockManager::ContentBlockDocumentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  it "exists with required data" do
    content_block_document = create(
      :content_block_document,
      :email_address,
      content_id: "52084b2d-4a52-4e69-ba91-3052b07c7eb6",
      sluggable_string: "Title",
      created_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
      updated_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
    )

    assert_equal "52084b2d-4a52-4e69-ba91-3052b07c7eb6", content_block_document.content_id
    assert_equal "Title", content_block_document.sluggable_string
    assert_equal "email_address", content_block_document.block_type
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_document.created_at
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_document.updated_at
    assert_equal "title", content_block_document.content_id_alias
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

    it "returns embed code for a particular field" do
      uuid = SecureRandom.uuid
      document = create(:content_block_document, :pension, content_id: uuid)

      assert_equal document.embed_code_for_field("rates/rate2/name"), "{{embed:content_block_pension:#{uuid}/rates/rate2/name}}"
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

  describe "friendly_id" do
    it "generates a content_id_alias" do
      content_block_document = create(
        :content_block_document,
        :email_address,
        sluggable_string: "This is a title",
      )

      assert_equal "this-is-a-title", content_block_document.content_id_alias
    end

    it "ensures content_id_aliases are unique" do
      content_block_documents = create_list(
        :content_block_document,
        2,
        :email_address,
        sluggable_string: "This is a title",
      )

      assert_equal "this-is-a-title", content_block_documents[0].content_id_alias
      assert_equal "this-is-a-title--2", content_block_documents[1].content_id_alias
    end

    it "does not change the alias if the sluggable string changes" do
      content_block_document = create(
        :content_block_document,
        :email_address,
        sluggable_string: "This is a title",
      )

      content_block_document.sluggable_string = "Something else"
      content_block_document.save!

      assert_equal "this-is-a-title", content_block_document.content_id_alias
    end
  end

  describe "title" do
    it "returns the latest edition's title" do
      document = create(:content_block_document, :email_address)
      _oldest_edition = create(:content_block_edition, document:)
      latest_edition = create(:content_block_edition, document:, title: "I am the latest edition")

      assert_equal latest_edition.title, document.title
    end
  end

  describe "#is_new_block?" do
    it "returns true when there is one associated edition" do
      document = create(:content_block_document, :email_address, editions: create_list(:content_block_edition, 1, :email_address))

      assert document.is_new_block?
    end

    it "returns false when there is more than one associated edition" do
      document = create(:content_block_document, :email_address, editions: create_list(:content_block_edition, 2, :email_address))

      assert_not document.is_new_block?
    end
  end

  describe "#has_newer_draft?" do
    let(:document) { create(:content_block_document, :email_address) }

    it "returns false when the newest edition is the same as the latest edition" do
      _older_edition = create(:content_block_edition, :email_address, created_at: Time.zone.now - 2.days, document:)
      edition = create(:content_block_edition, :email_address, created_at: Time.zone.now, document:)
      document.latest_edition_id = edition.id
      document.save!

      assert_not document.has_newer_draft?
    end

    it "returns true when the newest edition is not the same as the latest edition" do
      edition = create(:content_block_edition, :email_address, created_at: Time.zone.now - 2.days, document:)
      _newer_edition = create(:content_block_edition, :email_address, created_at: Time.zone.now, document:)
      document.latest_edition_id = edition.id
      document.save!

      assert document.has_newer_draft?
    end
  end

  describe "#latest_draft" do
    let(:document) { create(:content_block_document, :email_address) }

    it "returns the latest draft edition" do
      _older_draft = create(:content_block_edition, :email_address, created_at: Time.zone.now - 2.days, document:, state: "draft")
      newest_draft = create(:content_block_edition, :email_address, created_at: Time.zone.now - 1.day, document:, state: "draft")
      _newest_edition = create(:content_block_edition, :email_address, created_at: Time.zone.now, document:, state: "published")

      assert_equal newest_draft, document.latest_draft
    end
  end
end
