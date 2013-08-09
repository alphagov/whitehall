require "test_helper"

class CaseStudyTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_image_attachments
  should_have_first_image_pulled_out
  should_protect_against_xss_and_content_attacks_on :body

  test "should be able to relate to policies" do
    article = build(:case_study)
    assert article.can_be_related_to_policies?
  end

  test "can be associated with worldwide priorities" do
    assert CaseStudy.new.can_be_associated_with_worldwide_priorities?
  end

  test 'search_format_types tags the case study as a case-study' do
    case_study = build(:case_study)
    assert case_study.search_format_types.include?('case-study')
  end

  test "should be translatable" do
    assert build(:case_study).translatable?
  end

  test "is not translatable when non-English" do
    refute build(:case_study, locale: :es).translatable?
  end

  test 'imported case study is valid when the first_published_at is blank' do
    case_study = build(:case_study, state: 'imported', first_published_at: nil)
    assert case_study.valid?
  end

  test 'imported case_study is not valid_as_draft? when the first_published_at is blank, but draft case_study is' do
    refute build(:case_study, state: 'imported', first_published_at: nil).valid_as_draft?
    assert build(:case_study, state: 'draft', first_published_at: nil).valid_as_draft?
  end
end
