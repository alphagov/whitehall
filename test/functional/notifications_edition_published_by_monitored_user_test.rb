require 'test_helper'

class NotificationsEditionPublishedByMonitoredUserTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @user = build(:user, name: "Jim Jimson", email: "jim@example.com")
    @mail = Notifications.edition_published_by_monitored_user(@user)
  end

  test "email should be sent to the content second line email address" do
    assert_equal [Notifications.new.send(:content_second_line_email_address)], @mail.to
  end

  test "email subject should include the name and email address of the user" do
    assert_equal "Account holder Jim Jimson (jim@example.com) has published to live", @mail.subject
  end

  test "email body should include the name and email address of the user" do
    assert_match Regexp.new("Jim Jimson"), @mail.body.to_s
    assert_match Regexp.new("jim@example.com"), @mail.body.to_s
  end
end
