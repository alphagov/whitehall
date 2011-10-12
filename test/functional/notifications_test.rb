require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @fact_check_request = create(:fact_check_request, email_address: 'fact-check@example.com')
    @requester = build(:user)
    @mail = Notifications.fact_check(@fact_check_request, @requester, host: "example.com")
  end

  test "fact check should be sent to the specified email address" do
    assert_equal ['fact-check@example.com'], @mail.to
  end

  test "fact check should be sent from a generic email address" do
    assert_equal ["fact-check-request@example.com"], @mail.from
  end

  test "fact check subject" do
    assert_equal "Fact checking request from #{@requester.name}", @mail.subject
  end

  test "fact check email should contain a policy link containing a token" do
    url = edit_admin_document_fact_check_request_url(@fact_check_request.document, @fact_check_request)
    assert_match /#{url}/, @mail.body.to_s
  end
end