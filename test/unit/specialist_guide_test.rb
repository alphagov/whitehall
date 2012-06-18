require "test_helper"

class SpecialistGuideTest < ActiveSupport::TestCase
  test "should be able to relate to topics" do
    article = build(:specialist_guide)
    assert article.can_be_associated_with_topics?
  end

  test "should have a summary" do
    assert build(:specialist_guide).has_summary?
  end
end
