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

  test "#update_lead_image updates the lead_image association to the oldest image" do
    image1 = build_stubbed(:image)
    image2 = build_stubbed(:image)
    case_study = build_stubbed(:case_study, images: [image1, image2])

    case_study.stubs(:lead_image).returns(nil)
    case_study.images.stubs(:order).with(:created_at, :id).returns([image1, image2])

    case_study.expects(:update_column)
    .with(:lead_image_id, image1.id)
    .returns(true)
    .once

    case_study.update_lead_image
  end

  test "#update_lead_image returns nil if lead_image is present" do
    case_study = build(:case_study)
    build(:image)
    case_study.stubs(:lead_image).returns(case_study)

    assert_nil case_study.update_lead_image
  end

  test "#update_lead_image returns nil if no images are present" do
    case_study = build(:case_study)
    assert_nil case_study.update_lead_image
  end

  test "#update_lead_image updates lead_image to nil if image_display_option is 'no_image'" do
    case_study = create(:case_study, image_display_option: "custom_image")

    case_study.expects(:update_column)
    .with(:lead_image_id, nil)
    .returns(true)
    .once

    case_study.update!(image_display_option: "no_image")
  end
end
