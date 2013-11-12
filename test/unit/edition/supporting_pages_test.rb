require "test_helper"

class Edition::SupportingPagesTest < ActiveSupport::TestCase
  test "#supporting_pages should return a supporting page related to this edition" do
    policy = create(:policy)
    supporting_page = create(:supporting_page, related_policies: [policy])

    assert_equal [supporting_page], policy.supporting_pages
  end

  test "#published_supporting_pages should only return published editions" do
    policy = create(:policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])
    supporting_page.create_draft(create(:policy_writer))
    create(:draft_supporting_page, related_policies: [policy])

    assert_equal [supporting_page], policy.published_supporting_pages
  end

  test "#active_supporting_pages should return the latest draft or published editions" do
    policy = create(:policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])
    other_page = create(:published_supporting_page, related_policies: [policy])
    draft = other_page.create_draft(create(:policy_writer))

    assert_equal [supporting_page, draft], policy.active_supporting_pages
  end
end
