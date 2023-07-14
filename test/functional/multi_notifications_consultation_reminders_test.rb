require "test_helper"

class MultiNotificationsConsultationRemindersTest < ActionMailer::TestCase
  setup do
    author = build(:author)
    @consultation = create(:consultation, authors: [author, author])
  end

  test "reminder emails should contain the title text and weeks remaining" do
    @email = MultiNotifications.consultation_deadline_upcoming(@consultation, weeks_left: 2)
    assert_includes @email.first.body.to_s, %(Publish the government response for "#{@consultation.title}" within 2 weeks)
    assert_equal 1, @email.length
  end

  test "overdue notifications should contain the title text" do
    @email = MultiNotifications.consultation_deadline_passed(@consultation)
    assert_includes @email.first.body.to_s, %(Publish the "#{@consultation.title}" response as soon as possible)
    assert_equal 1, @email.length
  end
end
