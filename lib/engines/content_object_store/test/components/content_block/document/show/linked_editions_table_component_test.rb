require "test_helper"

class ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  it "renders linked editions with an organisation" do
    caption = "Some caption"
    organisation = build(:organisation, id: 123)
    linked_content_items = [
      ContentObjectStore::ContentItem.new(title: "Some title", base_path: "/foo", document_type: "document_type", organisation:),
    ]

    render_inline(
      ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponent.new(
        caption:,
        linked_content_items:,
      ),
    )

    assert_selector ".govuk-table__caption", text: caption

    assert_selector "tbody .govuk-table__row", count: 1

    assert_selector "tbody .govuk-table__cell", text: linked_content_items[0].title
    assert_selector "tbody .govuk-table__cell", text: linked_content_items[0].document_type.humanize
    assert_selector "tbody .govuk-table__cell", text: organisation.name
  end

  it "renders linked editions without an organisation" do
    caption = "Some caption"
    linked_content_items = [
      ContentObjectStore::ContentItem.new(title: "Some title", base_path: "/foo", document_type: "document_type", organisation: nil),
    ]

    render_inline(
      ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponent.new(
        caption:,
        linked_content_items:,
      ),
    )

    assert_selector ".govuk-table__caption", text: caption

    assert_selector "tbody .govuk-table__row", count: 1

    assert_selector "tbody .govuk-table__cell", text: linked_content_items[0].title
    assert_selector "tbody .govuk-table__cell", text: linked_content_items[0].document_type.humanize
    assert_selector "tbody .govuk-table__cell", text: "Not set"
  end
end
