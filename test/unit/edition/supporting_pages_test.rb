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

  test "#active_supporting_pages should return the latest draft, submitted or published editions" do
    policy = create(:policy)
    published_page = create(:published_supporting_page, related_policies: [policy])
    other_page = create(:published_supporting_page, related_policies: [policy])
    draft_page = other_page.create_draft(create(:policy_writer))
    submitted_page = create(:submitted_supporting_page, related_policies: [policy])

    assert_equal [published_page, draft_page, submitted_page], policy.active_supporting_pages
  end

  test "#active_supporting_pages ignores newer deleted editions" do
    policy = create(:policy)
    old_edition       = create(:supporting_page, :superseded, related_policies: [policy])
    published_edition = create(:published_supporting_page, related_policies: [policy], document: old_edition.document)
    deleted_edition   = create(:supporting_page, :deleted, related_policies: [policy], document: old_edition.document)

    assert_equal [published_edition], policy.active_supporting_pages
  end
end
