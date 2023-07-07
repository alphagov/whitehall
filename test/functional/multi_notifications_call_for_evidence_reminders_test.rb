require "test_helper"

class MultiNotificationsCallForEvidenceRemindersTest < ActionMailer::TestCase
  setup do
    author = build(:author)
    @call_for_evidence = create(:call_for_evidence, authors: [author, author])
  end

  test "reminder emails should contain the title text" do
    @email = MultiNotifications.call_for_evidence_reminder(@call_for_evidence)
    assert_includes @email.first.body.to_s, %(This is a reminder that the call for evidence "#{@call_for_evidence.title}" closed 8 weeks ago and you may want to publish responses.)
    assert_equal 1, @email.length
  end
end
