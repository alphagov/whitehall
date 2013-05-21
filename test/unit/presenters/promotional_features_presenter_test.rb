require 'test_helper'

class PromotionalFeaturesPresenterTest < ActionView::TestCase
  setup do
    setup_view_context
  end

  test 'returns a position-aware enumerable collection of PromotionalFeaturePresenters' do
    organisation = create(:executive_office)
    single_feature = create(:promotional_feature, organisation: organisation)
    create(:promotional_feature_item, promotional_feature: single_feature)
    double_feature = create(:promotional_feature, organisation: organisation)
    create(:promotional_feature_item, promotional_feature: double_feature)
    create(:promotional_feature_item, promotional_feature: double_feature)
    triple_feature = create(:promotional_feature, organisation: organisation)
    create(:promotional_feature_item, promotional_feature: triple_feature)
    create(:promotional_feature_item, promotional_feature: triple_feature)
    create(:promotional_feature_item, promotional_feature: triple_feature)

    collection = PromotionalFeaturesPresenter.new([single_feature, double_feature, triple_feature], @view_context)
    expected_collection = [feature_presenter(single_feature, 0), feature_presenter(double_feature, 1), feature_presenter(triple_feature, 3)]
    assert_equal expected_collection, collection.to_a

    collection = PromotionalFeaturesPresenter.new([triple_feature, single_feature, double_feature], @view_context)
    expected_collection = [feature_presenter(triple_feature, 0), feature_presenter(single_feature, 3), feature_presenter(double_feature, 4)]
    assert_equal expected_collection, collection.to_a
  end

  private

  def feature_presenter(feature, position)
    PromotionalFeaturePresenter.new(feature, position, @view_context)
  end
end
