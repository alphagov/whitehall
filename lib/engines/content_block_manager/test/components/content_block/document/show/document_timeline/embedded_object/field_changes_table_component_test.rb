require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:field_diff) do
    {
      "email_address" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "old@email.com", new_value: "new@email.com"),
      "object" => {
        "something" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "old value", new_value: "new value"),
      },
    }
  end

  let(:content_block_edition) do
    build(:content_block_edition, details: { "my_subschema" => { "something" => { "title" => "My thing" } } })
  end

  it "renders the edition diff table" do
    render_inline(
      ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponent.new(
        object_id: "something",
        field_diff:,
        subschema_id: "my_subschema",
        content_block_edition:,
      ),
    )

    assert_selector ".govuk-table__caption", text: "My thing"

    assert_selector "tr:nth-child(1) th:nth-child(1)", text: "Email address"
    assert_selector "tr:nth-child(1) td:nth-child(2)", text: "old@email.com"
    assert_selector "tr:nth-child(1) td:nth-child(3)", text: "new@email.com"

    assert_selector "tr:nth-child(2) th:nth-child(1)", text: "Object something"
    assert_selector "tr:nth-child(2) td:nth-child(2)", text: "old value"
    assert_selector "tr:nth-child(2) td:nth-child(3)", text: "new value"
  end

  describe "when a title cannot be found for the object" do
    let(:content_block_edition) do
      build(:content_block_edition, details: {})
    end

    it "humanizes the object ID" do
      render_inline(
        ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponent.new(
          object_id: "something",
          field_diff:,
          subschema_id: "my_subschema",
          content_block_edition:,
        ),
      )

      assert_selector ".govuk-table__caption", text: "Something"
    end
  end
end
