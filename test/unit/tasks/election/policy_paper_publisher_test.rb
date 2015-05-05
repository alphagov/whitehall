require 'test_helper'
require 'tasks/election/policy_paper_publisher'

class PolicyPaperPublisherTest < ActiveSupport::TestCase
  setup do
    @policy_paper = create(:draft_policy_paper,
      first_published_at: 1.year.ago
    )
    Election::PolicyPaperPublisher.new([@policy_paper.id]).run!
    @policy_paper.reload
  end

  test "it publishes the policy paper" do
    assert @policy_paper.published?
  end

  test "it publishes as a minor change" do
    assert @policy_paper.minor_change?
  end

  test "it retains the first_published_at from the draft" do
    assert_equal 1.year.ago, @policy_paper.first_published_at
  end

  test "it sets the major change timestamp to match the first published timestamp" do
    assert_equal @policy_paper.first_published_at, @policy_paper.major_change_published_at
  end
end
