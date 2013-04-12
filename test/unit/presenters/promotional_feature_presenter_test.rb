class PromotionalFeaturePresenterTest < ActionView::TestCase
  setup do
    ApplicationController.new.set_current_view_context
  end

  test "#width returns the sum of the presenter feature's items widths" do
    assert_equal 0, feature_presenter.width
    assert_equal 1, feature_presenter([build(:promotional_feature_item)]).width
    assert_equal 2, feature_presenter([build(:promotional_feature_item), build(:promotional_feature_item)]).width
    assert_equal 3, feature_presenter([build(:promotional_feature_item), build(:promotional_feature_item, double_width: true)]).width
  end

  test "#width_class returns the appropriate class based on the feature's width" do
    assert_equal "features-1", feature_presenter([build(:promotional_feature_item)]).width_class
    assert_equal "features-2", feature_presenter([build(:promotional_feature_item), build(:promotional_feature_item)]).width_class
    assert_equal "features-3", feature_presenter([build(:promotional_feature_item), build(:promotional_feature_item, double_width: true)]).width_class
  end

  test "can be initialized with the rest of the collection?" do
    feature = PromotionalFeaturePresenter.new(build(:promotional_feature), collection: [:stuff, :etc])

    assert_equal [:stuff, :etc], feature.options[:collection]
  end

  test "returns it's position based on the passed in option value" do
    assert_equal 123, feature_presenter([], position: 123).position
    assert_equal 321, feature_presenter([], position: 321).position
  end

  test "#clear_class returns 'clear-promo' when the position is a modulus of 3" do
    assert_equal 'clear-promo', feature_presenter([], position: 0).clear_class
    assert_nil                  feature_presenter([], position: 1).clear_class
    assert_nil                  feature_presenter([], position: 2).clear_class
    assert_equal 'clear-promo', feature_presenter([], position: 3).clear_class
    assert_nil                  feature_presenter([], position: 4).clear_class
    assert_nil                  feature_presenter([], position: 5).clear_class
    assert_equal 'clear-promo', feature_presenter([], position: 6).clear_class
  end

  private

  def feature_presenter(items=[], options={})
    PromotionalFeaturePresenter.new(build(:promotional_feature, promotional_feature_items: items), options)
  end
end
