require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @fact_check_request = create(:fact_check_request, email_address: 'fact-check@example.com')
    @mail = Notifications.fact_check(@fact_check_request)
  end

  test "fact check should be sent to the specified email address" do
    assert_equal ['fact-check@example.com'], @mail.to
  end

  test "fact check should be sent from a generic email address" do
    assert_equal ["fact-check-request@#{Whitehall.domain}"], @mail.from
  end

  test "fact check subject" do
    assert_equal "Fact checking request", @mail.subject
  end

  test "fact check email should contain a policy link containing a token" do
    edition = @fact_check_request.edition
    url = edit_admin_edition_fact_check_request_url(edition.to_param, @fact_check_request.to_param)
    assert_match /#{url}/, @mail.body.to_s
  end
end