require 'test_helper'
require 'tasks/election/policy_paper_publisher'

class PolicyPaperPublisherTest < ActiveSupport::TestCase
  setup do
    @policy_paper = create(:draft_policy_paper,
      first_published_at: 1.year.ago
    )

    @gds_user = FactoryGirl.create(:user, email: "govuk-whitehall@digital.cabinet-office.gov.uk")

    Election::PolicyPaperPublisher.new([@policy_paper.id]).run!

    @policy_paper.reload
  end

  test "it publishes the policy paper" do
    assert @policy_paper.published?
  end

  test "it doesn't send emails" do
    Whitehall::GovUkDelivery::Worker.expects(:notify!).never
  end

  test "it retains the first_published_at from the draft" do
    assert_equal 1.year.ago, @policy_paper.first_published_at
  end

  test "doesn't explode if given a published publication" do
    policy_paper = create(:published_policy_paper)
    Election::PolicyPaperPublisher.new([policy_paper.id]).run!
  end

  test "it sets the public_timestamp to 24 hours ago" do
    assert_equal Time.zone.now - 1.day, @policy_paper.public_timestamp
  end

  test "it publishes as the GDS user" do
    assert_equal @gds_user, @policy_paper.versions.where(state: "published").last.user
  end
end
