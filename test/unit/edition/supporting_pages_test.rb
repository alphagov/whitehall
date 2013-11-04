require "test_helper"

class Edition::SupportingPagesTest < ActiveSupport::TestCase
  test "#supporting_pages should return a supporting page related to this edition" do
    policy = create(:policy)
    supporting_page = create(:supporting_page, related_policies: [policy])

    assert_equal [supporting_page], policy.supporting_pages
  end
end
