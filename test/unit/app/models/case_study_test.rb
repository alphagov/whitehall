require "test_helper"

class CaseStudyTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_be_attachable
  should_allow_inline_attachments
  should_have_custom_lead_image
  should_protect_against_xss_and_content_attacks_on :case_study, :body

  test "should be translatable" do
    assert build(:case_study).translatable?
  end

  test "is not translatable when non-English" do
    assert_not build(:case_study, primary_locale: :es).translatable?
  end
end
