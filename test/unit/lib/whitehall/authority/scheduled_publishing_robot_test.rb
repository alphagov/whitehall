require_relative "authority_test_helper"
require "ostruct"

class ScheduledPublishingRobotTest < ActiveSupport::TestCase
  def scheduled_publishing_robot(id = 1)
    OpenStruct.new(
      id:,
      gds_editor?: false,
      departmental_editor?: false,
      scheduled_publishing_robot?: true,
      organisation: nil,
      can_publish_scheduled_editions?: true,
    )
  end

  include AuthorityTestHelper

  test "can publish a scheduled edition" do
    assert enforcer_for(scheduled_publishing_robot, scheduled_edition).can?(:publish)
  end
end
