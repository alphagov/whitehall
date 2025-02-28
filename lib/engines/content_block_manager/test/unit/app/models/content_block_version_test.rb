require "test_helper"

class ContentBlockManager::ContentBlockVersionTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:event) { "created" }
  let(:item) do
    create(
      :content_block_edition,
      document: create(:content_block_document, :email_address),
    )
  end
  let(:whodunnit) { SecureRandom.uuid }
  let(:field_diffs) do
    {
      "some_field" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "previous value", new_value: "new value"),
    }
  end

  let(:content_block_version) do
    ContentBlockManager::ContentBlock::Version.new(
      event:,
      item:,
      whodunnit:,
    )
  end

  it "exists with required data" do
    content_block_version.save!

    assert_equal event, content_block_version.event
    assert_equal item, content_block_version.item
    assert_equal whodunnit, content_block_version.whodunnit
  end

  it "exists with optional state" do
    content_block_version.update!(state: "scheduled")

    assert_equal "scheduled", content_block_version.state
  end

  it "exists with optional field_diffs" do
    content_block_version.update!(field_diffs:)

    assert_equal field_diffs, content_block_version.field_diffs
  end

  it "validates the presence of a correct event" do
    assert_raises(ArgumentError) do
      _content_block_version = create(
        :content_block_version,
        event: "invalid",
      )
    end
  end

  describe "#field_diffs" do
    it "returns the field diffs as typed objects" do
      hash = {
        "foo" => { "previous_value" => "bar", "new_value" => "baz" },
      }

      content_block_version.field_diffs = hash

      assert_equal ContentBlockManager::ContentBlock::DiffItem.from_hash(hash), content_block_version.field_diffs
    end

    it "returns an empty hash when the value is nil" do
      content_block_version.field_diffs = nil

      assert_equal ({}), content_block_version.field_diffs
    end
  end

  describe "#is_embedded_update?" do
    it "returns false by default" do
      assert_not content_block_version.is_embedded_update?
    end

    it "returns true when updated_embedded_object_type and updated_embedded_object_title are set" do
      content_block_version.updated_embedded_object_type = "something"
      content_block_version.updated_embedded_object_title = "something"

      assert content_block_version.is_embedded_update?
    end
  end
end
