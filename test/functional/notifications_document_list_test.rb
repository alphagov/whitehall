require 'test_helper'

class NotificationsDocumentListTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @csv = "column1,column2\ncolumn3,column4"
    @address = "test@example.com"
    @filter_title = "Test"
    @mail = Notifications.document_list(@csv, @address, @filter_title)
  end

  test "email should be sent to the correct address" do
    assert_equal @mail.to, [@address]
  end

  test "email subject should include filter title" do
    assert_equal @mail.subject, "Test from GOV.UK"
  end

  test "email attachment should include zipped CSV file" do
    attachment = @mail.attachments["document_list.zip"]

    Zip::InputStream.open(StringIO.new(attachment.body.to_s)) do |zip|
      entry = zip.get_next_entry
      assert_equal entry.name, "document_list.csv"
      assert_equal zip.read, @csv
    end
  end
end
