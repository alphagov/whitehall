require "test_helper"

class CaseStudyTest < EditionTestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_allow_a_summary_to_be_written
  should_allow_a_body_to_be_written
  should_protect_against_xss_and_content_attacks_on :body

  test "should be able to relate to policies" do
    article = build(:case_study)
    assert article.can_be_related_to_policies?
  end

end
