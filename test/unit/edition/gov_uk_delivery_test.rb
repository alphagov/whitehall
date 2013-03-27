require "test_helper"

class Edition::GovUkDeliveryTest < ActiveSupport::TestCase
  test "should build gov uk delivery query" do
    policy = create(:policy, topics: [create(:topic), create(:topic)])
    policy.first_published_at = Time.zone.now
    policy.major_change_published_at = Time.zone.now
    Edition::AuditTrail.whodunnit = create(:user)
    policy.publish!
  end

end