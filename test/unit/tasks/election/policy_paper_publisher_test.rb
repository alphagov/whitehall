require 'test_helper'
require 'tasks/election/policy_paper_publisher'

class PolicyPaperPublisherTest < ActiveSupport::TestCase
  setup do
    @policy_paper = create(:draft_policy_paper,
      first_published_at: 1.year.ago
    )

    @gds_user = FactoryGirl.create(:user, email: "govuk-whitehall@digital.cabinet-office.gov.uk")

    Whitehall::GovUkDelivery::Worker.stubs(:notify!)
    Whitehall::SearchIndex.stubs(:add)
    ServiceListeners::PanopticonRegistrar.any_instance.stubs(:register!)
  end

  test "it publishes the policy paper" do
    publish_policy_paper
    assert @policy_paper.published?
  end

  test "it doesn't send emails" do
    Whitehall::GovUkDelivery::Worker.expects(:notify!).never
    publish_policy_paper
  end

  test "it indexes the policy paper" do
    Whitehall::SearchIndex.expects(:add).with(@policy_paper)
    publish_policy_paper
  end

  test "it registers the policy paper with panopticon" do
    registrar = stub(:registrar)
    ServiceListeners::PanopticonRegistrar.stubs(:new).with(@policy_paper).returns(registrar)
    registrar.expects(:register!).once
    publish_policy_paper
  end

  test "it registers the policy paper with the publishing API" do
    Whitehall::PublishingApi.expects(:publish_async).with(@policy_paper)
    publish_policy_paper
  end

  test "it retains the first_published_at from the draft" do
    publish_policy_paper
    assert_equal 1.year.ago, @policy_paper.first_published_at
  end

  test "doesn't explode if given a published publication" do
    @policy_paper = create(:published_policy_paper)
    publish_policy_paper
  end

  test "it sets the public_timestamp to 24 hours ago" do
    publish_policy_paper
    assert_equal Time.zone.now - 1.day, @policy_paper.public_timestamp
  end

  test "it creates a change note marking the historical nature of the policy paper" do
    publish_policy_paper
    assert_equal "Policy document from the 2010 to 2015 government preserved in a different format for reference",
                 @policy_paper.change_note
  end

  test "it publishes as the GDS user" do
    publish_policy_paper
    assert_equal @gds_user, @policy_paper.versions.where(state: "published").last.user
  end

  def publish_policy_paper
    Election::PolicyPaperPublisher.new([@policy_paper.id]).run!
    @policy_paper.reload
  end
end
