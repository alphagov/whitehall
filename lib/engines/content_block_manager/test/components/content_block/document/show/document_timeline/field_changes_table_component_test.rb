require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:user) { build_stubbed(:user) }
  let(:schema) { stub(:schema, fields: %w[email_address]) }

  it "renders the edition diff table in correct order" do
    field_diffs = {
      "title" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "old title", new_value: "new title"),
      "details" => {
        "email_address" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "old@email.com", new_value: "new@email.com"),
      },
      "instructions_to_publishers" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "old instructions", new_value: "new instructions"),
    }
    version = build(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "published",
      field_diffs: field_diffs,
    )

    render_inline(
      ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent.new(
        version:,
        schema:,
      ),
    )

    assert_selector "tr:nth-child(1) th:nth-child(1)", text: "Title"
    assert_selector "tr:nth-child(1) td:nth-child(2)", text: "old title"
    assert_selector "tr:nth-child(1) td:nth-child(3)", text: "new title"

    assert_selector "tr:nth-child(2) th:nth-child(1)", text: "Email address"
    assert_selector "tr:nth-child(2) td:nth-child(2)", text: "old@email.com"
    assert_selector "tr:nth-child(2) td:nth-child(3)", text: "new@email.com"

    assert_selector "tr:nth-child(3) th:nth-child(1)", text: "Instructions to publishers"
    assert_selector "tr:nth-child(3) td:nth-child(2)", text: "old instructions"
    assert_selector "tr:nth-child(3) td:nth-child(3)", text: "new instructions"
  end
end
