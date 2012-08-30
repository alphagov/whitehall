require "test_helper"

class CaseStudyTest < EditionTestCase
  include ActionDispatch::TestProcess

  test "should be able to relate to policies" do
    article = build(:case_study)
    assert article.can_be_related_to_policies?
  end

end
