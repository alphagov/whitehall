require "test_helper"

class ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  PageData = Data.define(:total_items, :total_pages, :current_page)

  it "renders linked editions with an organisation" do
    caption = "Some caption"
    organisation = build(:organisation, id: 123)
    linked_content_items = [
      ContentObjectStore::ContentItem.new(title: "Some title", base_path: "/foo", document_type: "document_type", organisation:),
    ]
    page_data = PageData.new(total_items: 0, total_pages: 0, current_page: 0)
    page_path = "/some-path"

    render_inline(
      ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponent.new(
        caption:,
        linked_content_items:,
        page_data:,
        page_path:,
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
    page_data = PageData.new(total_items: 0, total_pages: 0, current_page: 0)
    page_path = "/some-path"

    render_inline(
      ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponent.new(
        caption:,
        linked_content_items:,
        page_data:,
        page_path:,
      ),
    )

    assert_selector ".govuk-table__caption", text: caption

    assert_selector "tbody .govuk-table__row", count: 1

    assert_selector "tbody .govuk-table__cell", text: linked_content_items[0].title
    assert_selector "tbody .govuk-table__cell", text: linked_content_items[0].document_type.humanize
    assert_selector "tbody .govuk-table__cell", text: "Not set"
  end

  it "doesn't render the pagination when there are no pages" do
    caption = "Some caption"
    linked_content_items = [
      ContentObjectStore::ContentItem.new(title: "Some title", base_path: "/foo", document_type: "document_type", organisation: nil),
    ]
    page_data = PageData.new(total_items: 0, total_pages: 0, current_page: 0)
    page_path = "/some-path"

    render_inline(
      ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponent.new(
        caption:,
        linked_content_items:,
        page_data:,
        page_path:,
      ),
    )

    assert_no_css ".govuk-pagination"
  end

  it "renders the pagination with correct path when there are pages" do
    caption = "Some caption"
    linked_content_items = [
      ContentObjectStore::ContentItem.new(title: "Some title", base_path: "/foo", document_type: "document_type", organisation: nil),
    ]
    page_data = PageData.new(total_items: 30, total_pages: 3, current_page: 0)
    page_path = "/some-path"

    render_inline(
      ContentObjectStore::ContentBlock::Document::Show::LinkedEditionsTableComponent.new(
        caption:,
        linked_content_items:,
        page_data:,
        page_path:,
      ),
    )

    assert_selector ".govuk-pagination"
    assert_selector "a[href='#{page_path}?page=1']"
  end
end
