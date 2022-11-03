require "test_helper"

class CaseStudyTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_have_first_image_pulled_out
  should_protect_against_xss_and_content_attacks_on :case_study, :body

  test "search_format_types tags the case study as a case-study" do
    case_study = build(:case_study)
    assert case_study.search_format_types.include?("case-study")
  end

  test "should be translatable" do
    assert build(:case_study).translatable?
  end

  test "is not translatable when non-English" do
    assert_not build(:case_study, primary_locale: :es).translatable?
  end
end
