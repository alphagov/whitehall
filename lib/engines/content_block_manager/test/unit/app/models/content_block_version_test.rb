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
    [
      ContentBlockManager::ContentBlock::FieldDiff.new(
        field_name: "some_field",
        new_value: "new value",
        previous_value: "previous value",
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
end
