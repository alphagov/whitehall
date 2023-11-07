# frozen_string_literal: true

require "test_helper"
class Admin::Editions::Show::AttachmentsSummaryCardComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  test "renders the list of attachments with a view link when the edition is published" do
    attachments = build_stubbed_list(:file_attachment, 3, attachment_data: build(:attachment_data))
    edition = build_stubbed(:published_edition, attachments:)

    render_inline(Admin::Editions::Show::AttachmentsSummaryCardComponent.new(edition:))

    attachments.each do |attachment|
      assert_selector ".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__key", text: attachment.title
      assert_selector ".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__value", text: "#{attachment.readable_type.upcase_first} attachment"
      assert_selector ".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__actions a[href=\"#{attachment.url(full_url: true)}\"]", text: "View #{attachment.title}"
    end
  end

  test "renders the list of attachments with view and edit links when the edition is editable" do
    attachments = build_stubbed_list(:file_attachment, 3, attachment_data: build(:attachment_data))
    edition = build_stubbed(:draft_edition, attachments:)

    render_inline(Admin::Editions::Show::AttachmentsSummaryCardComponent.new(edition:))

    attachments.each do |attachment|
      edit_href = edit_admin_edition_attachment_path(edition, attachment)
      assert_selector ".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__key", text: attachment.title
      assert_selector ".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__value", text: "#{attachment.readable_type.upcase_first} attachment"
      assert_selector ".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__actions a[href=\"#{attachment.url(full_url: true)}\"]", text: "View #{attachment.title}"
      assert_selector ".govuk-summary-list .govuk-summary-list__row .govuk-summary-list__actions a[href=\"#{edit_href}\"]", text: "Edit #{attachment.title}"
    end
  end

  test "renders a link to the attachments page" do
    edition = build_stubbed(:draft_edition)

    render_inline(Admin::Editions::Show::AttachmentsSummaryCardComponent.new(edition:))

    assert_selector ".govuk-summary-card__action a[href=\"#{admin_edition_attachments_path(edition)}\"]", text: "Manage attachments"
  end
end
