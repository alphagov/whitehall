require "test_helper"

class SpecialistGuideTest < ActiveSupport::TestCase
  test "should be able to relate to other editions" do
    article = build(:specialist_guide)
    assert article.can_be_related_to_policies?
  end
end
