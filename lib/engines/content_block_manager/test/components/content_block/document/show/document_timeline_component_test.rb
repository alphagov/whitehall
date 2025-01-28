require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  extend Minitest::Spec::DSL

  let(:user) { create(:user) }

  test "renders a timeline component with events in correct order" do
    item = build(:content_block_edition, :email_address, change_note: nil, internal_change_note: nil)
    version_1 = create(
      :content_block_version,
      event: "created",
      whodunnit: user.id,
      item:,
    )
    version_2 = create(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "published",
      item:,
    )
    version_3 = create(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "scheduled",
      item:,
    )

    render_inline(ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent.new(
                    content_block_versions: [version_3, version_2, version_1],
                  ))

    assert_selector ".timeline__item", count: 2

    assert_equal "Email address scheduled", page.all(".timeline__title")[0].text
    assert_equal "by #{linked_author(user, { class: 'govuk-link' })}", page.all(".timeline__byline")[0].native.inner_html
    assert_equal  I18n.l(version_3.created_at, format: :long_ordinal),
                  page.all("time[datetime='#{version_3.created_at.iso8601}']")[1].text

    assert_equal "Email address published", page.all(".timeline__title")[1].text
    assert_equal "by #{linked_author(user, { class: 'govuk-link' })}", page.all(".timeline__byline")[1].native.inner_html
    assert_equal  I18n.l(version_2.created_at, format: :long_ordinal),
                  page.all("time[datetime='#{version_2.created_at.iso8601}']")[1].text

    assert_no_selector ".govuk-table"
    assert_no_selector "h2", text: "Internal note"
    assert_no_selector "h2", text: "Public note"
  end

  test "renders the edition diff table in correct order" do
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
    version = create(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "scheduled",
      field_diffs: field_diffs,
    )

    render_inline(ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent.new(
                    content_block_versions: [version],
                  ))

    assert_equal "old title", page.all("td")[0].text
    assert_equal "new title", page.all("td")[1].text
    assert_equal "old@email.com", page.all("td")[2].text
    assert_equal "new@email.com", page.all("td")[3].text
    assert_equal "old instructions", page.all("td")[4].text
    assert_equal "new instructions", page.all("td")[5].text
  end

  test "renders an internal change note" do
    edition = create(:content_block_edition, :email_address, internal_change_note: "changed x to y")
    version = create(
      :content_block_version,
      item: edition,
      event: "updated",
      state: "published",
    )

    render_inline(ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent.new(
                    content_block_versions: [version],
                  ))

    assert_selector "p", text: "changed x to y"
  end

  test "renders a public change note" do
    edition = create(:content_block_edition, :email_address, change_note: "changed a to b")
    version = create(
      :content_block_version,
      item: edition,
      event: "updated",
      state: "published",
    )

    render_inline(ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent.new(
                    content_block_versions: [version],
                  ))

    assert_selector "p", text: "changed a to b"
  end
end
