require "test_helper"

class CallForEvidenceReminderTest < ActiveSupport::TestCase
  setup { Timecop.freeze("2018/05/02 01:00:00".in_time_zone) }
  teardown { ActionMailer::Base.deliveries.clear }

  test ".send_reminder notifies authors of call for evidence reminder if today (past 24h) is exactly 8 weeks after close date without an outcome" do
    calls_for_evidence = [
      create_call_for_evidence(closing_at: "2018/03/06 01:01:00".in_time_zone),
      create_call_for_evidence(closing_at: "2018/03/06 02:30:00".in_time_zone),
      create_call_for_evidence(closing_at: "2018/03/06 23:45:00".in_time_zone),
      create_call_for_evidence(closing_at: "2018/03/07 00:30:00".in_time_zone),
      create_call_for_evidence(closing_at: "2018/03/07 01:00:00".in_time_zone),
    ]

    CallForEvidenceReminder.send_reminder

    assert_equal 5, ActionMailer::Base.deliveries.size

    calls_for_evidence.each do |call_for_evidence|
      assert ActionMailer::Base.deliveries.any? do |email|
        email.to.sort == call_for_evidence.authors.map(&:email).sort &&
          email.subject.includes?("Reminder: Call for evidence") &&
          email.body.includes?(call_for_evidence.title)
      end
    end
  end

  test ".send_reminder doesn't send notifications for calls for evidence if today (past 24h) is before 8 weeks after closing date" do
    create_call_for_evidence(closing_at: "2018/03/06 00:30:00".in_time_zone)
    create_call_for_evidence(closing_at: "2018/03/06 01:00:00".in_time_zone)
    CallForEvidenceReminder.send_reminder
    assert ActionMailer::Base.deliveries.empty?
  end

  test ".send_reminder doesn't send notifications for calls for evidence if today (past 24h) is after 8 weeks after closing date" do
    create_call_for_evidence(closing_at: "2018/03/07 01:01:00".in_time_zone)
    create_call_for_evidence(closing_at: "2018/03/07 02:00:00".in_time_zone)
    CallForEvidenceReminder.send_reminder
    assert ActionMailer::Base.deliveries.empty?
  end

  test ".send_reminder doesn't send notifications for calls for evidence if today (24h) is exactly 8 weeks after close but have an outcome" do
    create_call_for_evidence(closing_at: "2018/03/06 23:45:00".in_time_zone, responded: true)
    CallForEvidenceReminder.send_reminder
    assert ActionMailer::Base.deliveries.empty?
  end

  def create_call_for_evidence(closing_at:, responded: false)
    type = responded ? :call_for_evidence_with_outcome : :call_for_evidence
    FactoryBot.create(type, :published, opening_at: 10.months.ago, closing_at:)
  end
end
