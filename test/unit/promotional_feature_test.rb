require 'test_helper'

class PromotionalFeatureTest < ActiveSupport::TestCase
  test 'A feature with three items has reached its limit' do
    feature = create(:promotional_feature)

    3.times do
      refute feature.has_reached_item_limit?
      create(:promotional_feature_item, promotional_feature: feature)
    end

    assert feature.has_reached_item_limit?
  end

  test 'A feature with one normal item and one double-width item has reached its limit' do
    feature = create(:promotional_feature)
    create(:promotional_feature_item, promotional_feature: feature, double_width: true)
    refute feature.has_reached_item_limit?
    create(:promotional_feature_item, promotional_feature: feature)
    assert feature.has_reached_item_limit?
  end
end
