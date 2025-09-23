require "test_helper"

class AttachmentsHelperTest < ActionView::TestCase
  test "block_attachments renders an array of rendered attachments and ignores attachments with missing assets" do
    file_attachment_with_all_assets = create(:file_attachment)
    file_attachment_with_missing_assets = create(:file_attachment_with_no_assets)
    attachments = [
      create(:html_attachment),
      create(:external_attachment),
      file_attachment_with_all_assets,
      file_attachment_with_missing_assets,
    ]

    rendered_attachments = block_attachments(attachments)

    assert_equal attachments.length - 1, rendered_attachments.length

    rendered_attachments.each.with_index do |rendered, index|
      attachment = attachments[index]
      assert_select_within_html(rendered, ".gem-c-attachment")
      assert_select_within_html(rendered, ".gem-c-attachment__title a", text: attachment.title) do |link|
        assert_equal attachment.url, link.attr("href").to_s
      end
      assert_select_within_html(rendered, "a", text: attachment.alternative_format_contact_email) if index == 2
    end
  end

  test "generate errors for array of attachments uploaded via bulk uploader" do
    attachment = create(:csv_attachment, attachable: create(:edition))
    attachment.title = nil
    attachment.validate

    rendered = bulk_attachment_errors([attachment])

    assert_select_within_html rendered, ".govuk-error-summary"
    assert_select_within_html rendered, "a", href: "#bulk_upload[attachments][0]_title", text: "#{attachment.filename}: Title cannot be blank"
  end
end
