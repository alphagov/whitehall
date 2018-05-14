require "test_helper"

class NotificationsConsultationRemindersTest < ActionMailer::TestCase
  setup do
    @consultation = build(:consultation)
  end

  test "reminder emails should contain the title text and weeks remaining" do
    @email = Notifications.consultation_deadline_upcoming(@consultation, weeks_left: 2)
    assert_includes @email.body.to_s, %{Publish the government response for "#{@consultation.title}" within 2 weeks}
  end

  test "overdue notifications should contain the title text" do
    @email = Notifications.consultation_deadline_passed(@consultation)
    assert_includes @email.body.to_s, %{Publish the "#{@consultation.title}" response as soon as possible}
  end
end
