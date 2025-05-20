require "test_helper"

class ContentBlockManager::ContentBlockDocumentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  it "exists with required data" do
    content_block_document = create(
      :content_block_document,
      :pension,
      content_id: "52084b2d-4a52-4e69-ba91-3052b07c7eb6",
      sluggable_string: "Title",
      created_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
      updated_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
    )

    assert_equal "52084b2d-4a52-4e69-ba91-3052b07c7eb6", content_block_document.content_id
    assert_equal "Title", content_block_document.sluggable_string
    assert_equal "pension", content_block_document.block_type
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_document.created_at
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_document.updated_at
    assert_equal "title", content_block_document.content_id_alias
  end

  it "does not allow the block type to be changed" do
    content_block_document = create(:content_block_document, :pension)

    assert_raise ActiveRecord::ReadonlyAttributeError do
      content_block_document.update(block_type: "something_else")
    end
  end

  it "can store the id of the latest edition" do
    content_block_document = create(:content_block_document, :pension)
    content_block_document.update!(latest_edition_id: 1)
    assert content_block_document.reload.latest_edition_id, 1
  end

  it "can store the id of the live edition" do
    content_block_document = create(:content_block_document, :pension)
    content_block_document.update!(live_edition_id: 1)
    assert content_block_document.reload.live_edition_id, 1
  end

  it "gets its version history from its editions" do
    document = create(:content_block_document, :pension)
    edition = create(
      :content_block_edition,
      document:,
    )
    document.update!(editions: [edition])

    assert_equal document.versions.first.item.id, edition.id
  end

  describe "embed_code" do
    let(:content_id) { SecureRandom.uuid }
    let(:content_id_alias) { "some-alias" }
    let(:document) { build(:content_block_document, :pension, content_id:, content_id_alias:) }

    let(:strategy) { Flipflop::FeatureSet.current.test! }

    before do
      strategy.switch!(:use_friendly_embed_codes, use_friendly_embed_codes)
    end

    describe "when use_friendly_embed_codes? is false" do
      let(:use_friendly_embed_codes) { false }

      it "returns embed code for the document" do
        assert_equal document.embed_code, "{{embed:content_block_pension:#{content_id}}}"
      end

      it "returns embed code for a particular field" do
        assert_equal document.embed_code_for_field("rates/rate2/name"), "{{embed:content_block_pension:#{content_id}/rates/rate2/name}}"
      end
    end

    describe "when use_friendly_embed_codes? is true" do
      let(:use_friendly_embed_codes) { true }

      it "returns embed code for the document" do
        assert_equal document.embed_code, "{{embed:content_block_pension:#{content_id_alias}}}"
      end

      it "returns embed code for a particular field" do
        assert_equal document.embed_code_for_field("rates/rate2/name"), "{{embed:content_block_pension:#{content_id_alias}/rates/rate2/name}}"
      end
    end

    describe "when use_friendly_id is set manually" do
      let(:use_friendly_embed_codes) { false }

      it "returns embed code for the document" do
        assert_equal document.embed_code(use_friendly_id: true), "{{embed:content_block_pension:#{content_id_alias}}}"
        assert_equal document.embed_code(use_friendly_id: false), "{{embed:content_block_pension:#{content_id}}}"
      end

      it "returns embed code for a particular field" do
        assert_equal document.embed_code_for_field("rates/rate2/name", use_friendly_id: true), "{{embed:content_block_pension:#{content_id_alias}/rates/rate2/name}}"
        assert_equal document.embed_code_for_field("rates/rate2/name", use_friendly_id: false), "{{embed:content_block_pension:#{content_id}/rates/rate2/name}}"
      end
    end
  end

  describe "latest_edition" do
    it "returns the latest edition" do
      document = create(:content_block_document, :pension)
      _first_edition = create(:content_block_edition, document:)
      second_edition = create(:content_block_edition, document:)

      assert_equal second_edition, document.latest_edition
    end
  end

  describe ".live" do
    it "only returns documents with a latest edition" do
      document_with_latest_edition = create(:content_block_document, :pension)
      latest_edition = create(:content_block_edition, document: document_with_latest_edition)
      document_with_latest_edition.latest_edition_id = latest_edition.id
      document_with_latest_edition.save!

      create(:content_block_document, :pension, latest_edition_id: nil)

      assert_equal [document_with_latest_edition], ContentBlockManager::ContentBlock::Document.live
    end
  end

  describe "friendly_id" do
    it "generates a content_id_alias" do
      content_block_document = create(
        :content_block_document,
        :pension,
        sluggable_string: "This is a title",
      )

      assert_equal "this-is-a-title", content_block_document.content_id_alias
    end

    it "ensures content_id_aliases are unique" do
      content_block_documents = create_list(
        :content_block_document,
        2,
        :pension,
        sluggable_string: "This is a title",
      )

      assert_equal "this-is-a-title", content_block_documents[0].content_id_alias
      assert_equal "this-is-a-title--2", content_block_documents[1].content_id_alias
    end

    it "does not change the alias if the sluggable string changes" do
      content_block_document = create(
        :content_block_document,
        :pension,
        sluggable_string: "This is a title",
      )

      content_block_document.sluggable_string = "Something else"
      content_block_document.save!

      assert_equal "this-is-a-title", content_block_document.content_id_alias
    end
  end

  describe "title" do
    it "returns the latest edition's title" do
      document = create(:content_block_document, :pension)
      _oldest_edition = create(:content_block_edition, document:)
      latest_edition = create(:content_block_edition, document:, title: "I am the latest edition")

      assert_equal latest_edition.title, document.title
    end
  end

  describe "#is_new_block?" do
    it "returns true when there is one associated edition" do
      document = create(:content_block_document, :pension, editions: create_list(:content_block_edition, 1, :pension))

      assert document.is_new_block?
    end

    it "returns false when there is more than one associated edition" do
      document = create(:content_block_document, :pension, editions: create_list(:content_block_edition, 2, :pension))

      assert_not document.is_new_block?
    end
  end

  describe "#has_newer_draft?" do
    let(:document) { create(:content_block_document, :pension) }

    it "returns false when the newest edition is the same as the latest edition" do
      _older_edition = create(:content_block_edition, :pension, created_at: Time.zone.now - 2.days, document:)
      edition = create(:content_block_edition, :pension, created_at: Time.zone.now, document:)
      document.latest_edition_id = edition.id
      document.save!

      assert_not document.has_newer_draft?
    end

    it "returns true when the newest edition is not the same as the latest edition" do
      edition = create(:content_block_edition, :pension, created_at: Time.zone.now - 2.days, document:)
      _newer_edition = create(:content_block_edition, :pension, created_at: Time.zone.now, document:)
      document.latest_edition_id = edition.id
      document.save!

      assert document.has_newer_draft?
    end
  end

  describe "#latest_draft" do
    let(:document) { create(:content_block_document, :pension) }

    it "returns the latest draft edition" do
      _older_draft = create(:content_block_edition, :pension, created_at: Time.zone.now - 2.days, document:, state: "draft")
      newest_draft = create(:content_block_edition, :pension, created_at: Time.zone.now - 1.day, document:, state: "draft")
      _newest_edition = create(:content_block_edition, :pension, created_at: Time.zone.now, document:, state: "published")

      assert_equal newest_draft, document.latest_draft
    end
  end

  describe "#schema" do
    let(:document) { build(:content_block_document, :pension) }
    let(:schema) { build(:content_block_schema) }

    it "returns a schema object" do
      document.unstub(:schema)

      ContentBlockManager::ContentBlock::Schema
        .expects(:find_by_block_type)
        .with(document.block_type)
        .returns(schema)

      assert_equal document.schema, schema
    end
  end
end
