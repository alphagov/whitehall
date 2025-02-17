require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:user) { build_stubbed(:user) }

  it "renders the edition diff table in correct order" do
    field_diffs = [
      {
        "field_name": "title",
        "new_value": "new title",
        "previous_value": "old title",
      },
      {
        "field_name": "email_address",
        "new_value": "new@email.com",
        "previous_value": "old@email.com",
      },
      {
        "field_name": "instructions_to_publishers",
        "new_value": "new instructions",
        "previous_value": "old instructions",
      },
    ]
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
