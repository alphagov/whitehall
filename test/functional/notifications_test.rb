require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @policy = create(:policy)
    @fact_check_request = create(:fact_check_request, email_address: 'fact-check@example.com', document: @policy)
    @requester = build(:user)
    @mail = Notifications.fact_check(@fact_check_request, @requester, host: "example.com")
  end

  test "fact check should be sent to the specified email address" do
    assert_equal ['fact-check@example.com'], @mail.to
  end

  test "fact check should be sent from a generic email address" do
    assert_equal ["fact-check-request@example.com"], @mail.from
  end

  test "fact check subject contains the name of the requester and document title" do
    assert_equal "Fact checking request from #{@requester.name}: #{@policy.title}", @mail.subject
  end

  test "fact check email should contain a policy link containing a token" do
    url = edit_admin_document_fact_check_request_url(@fact_check_request.document, @fact_check_request)
    assert_match /#{url}/, @mail.body.to_s
  end

  test "fact check body contains the title of the document to be checked" do
    assert_match /#{Regexp.escape(@policy.title)}/, @mail.body.to_s
  end

  test "fact check body contains the type of the document to be checked" do
    assert_match /policy/, @mail.body.to_s
  end
end