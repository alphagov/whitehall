require "test_helper"

class ContentBlockManager::ContentBlockEditionTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:new_content_id) { SecureRandom.uuid }

  let(:created_at) { Time.zone.local(2000, 12, 31, 23, 59, 59).utc }
  let(:updated_at) { Time.zone.local(2000, 12, 31, 23, 59, 59).utc }
  let(:details) { { "some_field" => "some_content" } }
  let(:title) { "Document title" }
  let(:creator) { create(:user) }
  let(:organisation) { create(:organisation) }

  let(:content_block_edition) do
    ContentBlockManager::ContentBlock::Edition.new(
      created_at: created_at,
      updated_at: updated_at,
      details: details,
      document_attributes: {
        block_type: "email_address",
        title: title,
      },
      creator: creator,
      organisation_id: organisation.id.to_s,
    )
  end

  before do
    ContentBlockManager::ContentBlock::Edition.any_instance.stubs(:create_random_id).returns(new_content_id)
    content_block_edition.stubs(:schema).returns(build(:content_block_schema))
  end

  it "exists with required data" do
    content_block_edition.save!
    content_block_edition.reload

    assert_equal created_at, content_block_edition.created_at
    assert_equal updated_at, content_block_edition.updated_at
    assert_equal details, content_block_edition.details
  end

  it "persists the block type to the document" do
    content_block_edition.save!
    content_block_edition.reload
    document = content_block_edition.document

    assert_equal document.block_type, content_block_edition.block_type
  end

  it "persists the title to the document" do
    content_block_edition.save!
    content_block_edition.reload
    document = content_block_edition.document

    assert_equal document.title, content_block_edition.title
  end

  it "creates a document" do
    content_block_edition.save!
    content_block_edition.reload

    assert_not_nil content_block_edition.document
    assert_equal content_block_edition.document.content_id, new_content_id
  end

  it "adds a content id if a document is provided" do
    content_block_edition.document = build(:content_block_document, :email_address, content_id: nil)
    content_block_edition.save!
    content_block_edition.reload

    assert_not_nil content_block_edition.document
    assert_equal content_block_edition.document.content_id, new_content_id
  end

  it "validates the presence of a document block_type" do
    content_block_edition = build(
      :content_block_edition,
      created_at: created_at,
      updated_at: updated_at,
      details: details,
      document_attributes: {
        block_type: nil,
      },
      organisation_id: organisation.id.to_s,
    )

    assert_invalid content_block_edition
    assert content_block_edition.errors.full_messages.include?("Document block type can't be blank")
  end

  it "validates the presence of a document title" do
    content_block_edition = build(
      :content_block_edition,
      created_at: created_at,
      updated_at: updated_at,
      details: details,
      document_attributes: {
        title: nil,
      },
      organisation_id: organisation.id.to_s,
    )

    assert_invalid content_block_edition
    assert content_block_edition.errors.full_messages.include?("Title can't be blank")
  end

  it "adds a creator and first edition author for new records" do
    content_block_edition.save!
    content_block_edition.reload
    assert_equal content_block_edition.creator, content_block_edition.edition_authors.first.user
  end

  describe "#creator=" do
    it "raises an exception if called for a persisted record" do
      content_block_edition.save!
      assert_raise RuntimeError do
        content_block_edition.creator = create(:user)
      end
    end
  end

  describe "#update_document_reference_to_latest_edition!" do
    it "updates the document reference to the latest edition" do
      latest_edition = create(:content_block_edition, document: content_block_edition.document)
      latest_edition.update_document_reference_to_latest_edition!

      assert_equal latest_edition.document.latest_edition_id, latest_edition.id
    end
  end
end
