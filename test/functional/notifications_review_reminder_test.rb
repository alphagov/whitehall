require "test_helper"

class NotificationsReviewReminderTest < ActionMailer::TestCase
  enable_url_helpers
  include Admin::EditionRoutesHelper

  setup do
    document = create(:document)
    @edition = create(:publication, title: "Test title", document:)
    @title = @edition.title
    @review_reminder = create(:review_reminder, document:)
    @email_address = @review_reminder.email_address
    @mail = MailNotifications.review_reminder(@edition, recipient_address: @email_address)
  end

  test "email should be sent to the correct address" do
    assert_equal @mail.to, [@email_address]
  end

  test "email subject should include document title" do
    assert_equal @mail.subject, "#{@edition.format_name.capitalize} '#{@edition.title}' has reached its set review date"
  end

  test "email body should include details of the document being reviwed, a link to the summary page and a link to the relevant guidance" do
    assert @mail.body.raw_source.include?("A review date for the #{@edition.format_name} \"#{@title}\" has been set. The review date is today.")
    assert @mail.body.raw_source.include?(admin_edition_url(@edition))
    assert @mail.body.raw_source.include?("https://www.gov.uk/guidance/content-design/content-maintenance")
  end
end
