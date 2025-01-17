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
  let(:changed_fields) do
    [
      ContentBlockManager::ContentBlock::Version::ChangedField.new(
        field_name: "some_field",
        new: "new value",
        previous: "previous value",
      ),
    ].to_json
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

  it "exists with optional changed_fields" do
    content_block_version.update!(changed_fields:)

    assert_equal changed_fields, content_block_version.changed_fields
  end

  it "validates the presence of a correct event" do
    assert_raises(ArgumentError) do
      _content_block_version = create(
        :content_block_version,
        event: "invalid",
      )
    end
  end
end
