require "test_helper"

class AttachmentsHelperTest < ActionView::TestCase
  test "generate errors for array of attachments uploaded via uploader" do
    attachment = create(:csv_attachment, attachable: create(:edition))
    attachment.title = nil
    attachment.validate

    rendered = attachment_errors([attachment])

    assert_select_within_html rendered, ".govuk-error-summary"
    assert_select_within_html rendered, "a", href: "#upload[attachments][0]_title", text: "#{attachment.filename}: Title cannot be blank"
  end
end
