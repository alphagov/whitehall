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

  test "upload success message specifies each successful upload when there are five successful uploads" do
    attachments = create_list(:file_attachment, 5)
    notice_message = upload_success_notice_message(attachments)
    attachments.each do |attachment|
      assert notice_message =~ /#{attachment.title}/
    end
  end

  test "upload success notice message specifies the number of successful uploads when there are more than five successful uploads" do
    attachments = create_list(:file_attachment, 6)
    notice_message = upload_success_notice_message(attachments)
    assert notice_message =~ /6 attachments successfully saved/
  end
end
