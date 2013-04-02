require 'test_helper'

class PromotionalFeatureItemTest < ActiveSupport::TestCase

  test "invalid without a summary" do
    refute build(:promotional_feature_item, summary: nil).valid?
  end

  test "invalid without image on create" do
    refute build(:promotional_feature_item, image: nil).valid?
  end

  test "invalid without image alt text" do
    refute build(:promotional_feature_item, image_alt_text: nil).valid?
  end

  test "limits summary to a maximum of 500 characters" do
    assert build(:promotional_feature_item, summary: string_of_length(500)).valid?

    item = build(:promotional_feature_item, summary: string_of_length(501))
    refute item.valid?
    assert_equal ["is too long (maximum is 500 characters)"], item.errors[:summary]
  end

  private

  def string_of_length(length)
    'X' * length
  end
end
