require "test_helper"

class ImageDataTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid without a file" do
    image_data = build(:image_data, file: nil)
    assert_not image_data.valid?
  end

  test "returns unique auth_bypass_ids from its image's editions" do
    case_study_1 =  create(:case_study)
    case_study_2 =  create(:case_study)
    images_from_first_edition = (1..3).map { |i| Image.new(id: i, edition: case_study_1) }
    images_from_second_edition = (4..6).map { |i| Image.new(id: i, edition: case_study_2) }

    image_data = create(:image_data, images: images_from_first_edition + images_from_second_edition)

    assert_equal [case_study_1.auth_bypass_id, case_study_2.auth_bypass_id], image_data.auth_bypass_ids
  end
end
