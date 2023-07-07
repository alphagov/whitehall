require "test_helper"
require "rake"

class PublisherNotificationsRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#publisher_notifications:send" do
    let(:task) { Rake::Task["publisher_notifications:send"] }

    test "sends consultation reminders" do
      ConsultationReminder.expects(:send_all).once
      task.invoke
    end

    test "sends call for evidence reminders" do
      CallForEvidenceReminder.expects(:send_reminder).once
      task.invoke
    end
  end
end
