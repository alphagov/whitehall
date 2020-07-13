require "test_helper"

class NotificationsDocumentListTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @public_url = "https://whitehall.test.gov.uk/export/documents/#{SecureRandom.uuid}"
    @address = "test@example.com"
    @filter_title = "Test"
    @mail = Notifications.document_list(@public_url, @address, @filter_title)
  end

  test "email should be sent to the correct address" do
    assert_equal @mail.to, [@address]
  end

  test "email subject should include filter title" do
    assert_equal @mail.subject, "Test from GOV.UK"
  end

  test "email body should include url" do
    assert_match %r{\bhttps://whitehall\.test\.gov\.uk/export/documents/[a-f0-9-]{36}\b}, @mail.body.raw_source
  end
end
