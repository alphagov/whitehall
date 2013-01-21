require "test_helper"

class CaseStudyTest < EditionTestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_have_first_image_pulled_out
  should_protect_against_xss_and_content_attacks_on :body

  test "should be able to relate to policies" do
    article = build(:case_study)
    assert article.can_be_related_to_policies?
  end
end
