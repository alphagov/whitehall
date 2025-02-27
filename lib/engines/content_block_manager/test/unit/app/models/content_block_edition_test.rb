require "test_helper"

class ContentBlockManager::ContentBlockEditionTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:new_content_id) { SecureRandom.uuid }

  let(:created_at) { Time.zone.local(2000, 12, 31, 23, 59, 59).utc }
  let(:updated_at) { Time.zone.local(2000, 12, 31, 23, 59, 59).utc }
  let(:details) { { "some_field" => "some_content" } }
  let(:title) { "Edition title" }
  let(:creator) { create(:user) }
  let(:organisation) { create(:organisation) }
  let(:internal_change_note) { "My internal change note" }
  let(:change_note) { "My internal change note" }
  let(:major_change) { true }

  let(:content_block_edition) do
    ContentBlockManager::ContentBlock::Edition.new(
      created_at:,
      updated_at:,
      details:,
      document_attributes: {
        sluggable_string: "Something",
        block_type: "email_address",
      },
      creator:,
      organisation_id: organisation.id.to_s,
      title:,
      internal_change_note:,
      change_note:,
      major_change:,
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
    assert_equal title, content_block_edition.title
    assert_equal internal_change_note, content_block_edition.internal_change_note
    assert_equal change_note, content_block_edition.change_note
    assert_equal major_change, content_block_edition.major_change
  end

  it "persists the block type to the document" do
    content_block_edition.save!
    content_block_edition.reload
    document = content_block_edition.document

    assert_equal document.block_type, content_block_edition.block_type
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
      created_at:,
      updated_at:,
      details:,
      document_attributes: {
        block_type: nil,
      },
      organisation_id: organisation.id.to_s,
    )

    assert_invalid content_block_edition
    assert_includes content_block_edition.errors.messages[:"document.block_type"], I18n.t("activerecord.errors.models.content_block_manager/content_block/document.attributes.block_type.blank")
  end

  it "validates the presence of an edition title" do
    content_block_edition = build(
      :content_block_edition,
      created_at:,
      updated_at:,
      details:,
      document_attributes: {},
      organisation_id: organisation.id.to_s,
      title: nil,
    )

    assert_invalid content_block_edition
    assert content_block_edition.errors.full_messages.include?("Title cannot be blank")
  end

  describe "change note validation" do
    it "validates the presence of a change note if the change is major" do
      content_block_edition.change_note = nil
      content_block_edition.major_change = true

      assert_invalid content_block_edition, context: :change_note
      assert content_block_edition.errors.full_messages.include?("Change note cannot be blank")
    end

    it "is valid when the change is major and a change note is provided" do
      content_block_edition.change_note = "something"
      content_block_edition.major_change = true

      assert_valid content_block_edition, context: :change_note
    end

    it "validates the presence of the major_change boolean" do
      content_block_edition.major_change = nil

      assert_invalid content_block_edition, context: :change_note
      assert content_block_edition.errors.full_messages.include?("Select if users have to know the content has changed")
    end

    it "is valid when the change is minor and a change note is not provided" do
      content_block_edition.change_note = nil
      content_block_edition.major_change = false

      assert_valid content_block_edition, context: :change_note
    end
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

  describe ".current_versions" do
    it "returns current published versions" do
      document = create(:content_block_document, :email_address)
      edition = create(:content_block_edition, :email_address, state: "published", document:)
      draft_edition = create(:content_block_edition, :email_address, state: "draft", document:)
      document.latest_edition = draft_edition
      document.save!

      assert_equal ContentBlockManager::ContentBlock::Edition.current_versions.to_a, [edition]
    end
  end

  describe "#render" do
    let(:rendered_response) { "RENDERED" }
    let(:stub_block) { stub("ContentBlockTools::ContentBlock", render: rendered_response) }
    let(:document) { content_block_edition.document }
    let(:embed_code) { "embed_code" }

    it "initializes and renders a content block" do
      ContentBlockTools::ContentBlock.expects(:new)
                                     .with(
                                       document_type: "content_block_#{document.block_type}",
                                       content_id: document.content_id,
                                       title:,
                                       details:,
                                       embed_code:,
                                     ).returns(stub_block)

      assert_equal content_block_edition.render(embed_code), rendered_response
    end
  end

  describe "#add_object_to_details" do
    it "adds an object with the correct key to the details hash" do
      content_block_edition.add_object_to_details("something", { "name" => "My thing", "something" => "else" })

      assert_equal content_block_edition.details["something"], { "my-thing" => { "name" => "My thing", "something" => "else" } }
    end

    it "appends to the object if it already exists" do
      content_block_edition.details["something"] = {
        "another-thing" => {},
      }

      content_block_edition.add_object_to_details("something", { "name" => "My thing", "something" => "else" })
      assert_equal content_block_edition.details["something"], { "another-thing" => {}, "my-thing" => { "name" => "My thing", "something" => "else" } }
    end

    it "creates a random key if a name is not provided" do
      SecureRandom.expects(:alphanumeric).returns("RANDOM-STRING")
      content_block_edition.add_object_to_details("something", { "something" => "else" })

      assert_equal content_block_edition.details["something"], { "random-string" => { "something" => "else" } }
    end
  end

  describe "#update_object_with_details" do
    before do
      content_block_edition.details["something"] = { "my-thing" => { "name" => "My thing", "something" => "else" } }
    end

    it "updates a given object's details" do
      content_block_edition.update_object_with_details("something", "my-thing", { "name" => "My thing", "something" => "changed" })

      assert_equal content_block_edition.details["something"], { "my-thing" => { "name" => "My thing", "something" => "changed" } }
    end

    it "keeps the original key name if the name changes" do
      content_block_edition.update_object_with_details("something", "my-thing", { "name" => "Other thing", "something" => "changed" })

      assert_equal content_block_edition.details["something"], { "my-thing" => { "name" => "Other thing", "something" => "changed" } }
    end
  end

  describe "#clone_edition" do
    it "clones an edition in draft with the specified creator" do
      content_block_edition = create(
        :content_block_edition, :email_address,
        title: "Some title",
        details: { "my" => "details" },
        state: "published"
      )
      creator = create(:user)

      new_edition = content_block_edition.clone_edition(creator:)

      assert_equal new_edition.state, "draft"
      assert_nil new_edition.id
      assert_equal new_edition.organisation, content_block_edition.lead_organisation
      assert_equal new_edition.creator, creator
      assert_equal new_edition.title, content_block_edition.title
      assert_equal new_edition.details, content_block_edition.details
    end
  end

  describe "#first_class_details" do
    it "removed embedded objects" do
      content_block_edition = create(
        :content_block_edition, :email_address,
        title: "Some title",
        details: { "my" => "details", "embedded" => { "something" => { "is" => "here" } } },
        state: "published"
      )

      assert_equal content_block_edition.first_class_details, { "my" => "details" }
    end
  end

  describe "#has_entries_for_subschema_id?" do
    it "returns false when there are no entries for a subschema ID" do
      content_block_edition.details["foo"] = {}

      assert_not content_block_edition.has_entries_for_subschema_id?("foo")
    end

    it "returns true when there entries for a subschema ID" do
      content_block_edition.details["foo"] = { "something" => { "foo" => "bar" } }

      assert content_block_edition.has_entries_for_subschema_id?("foo")
    end
  end
end
