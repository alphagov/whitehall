require "test_helper"

class FeatureListPresenterTest < PresenterTestCase
  test "#current_feature_count the number of current featured editions (up to given limit)" do
    assert_equal 1, FeatureListPresenter.decorate(stub_feature_list).current_feature_count
    assert_equal 5, FeatureListPresenter.decorate(stub_feature_list(17)).current_feature_count
    assert_equal 7, FeatureListPresenter.decorate(stub_feature_list(17)).limit_to(7).current_feature_count
  end

  test "#any_current_features? indicates whether there are any current features" do
    assert FeatureListPresenter.decorate(stub_feature_list(1)).any_current_features?
    assert FeatureListPresenter.decorate(stub_feature_list(17)).any_current_features?
    refute FeatureListPresenter.decorate(stub_feature_list(0)).any_current_features?
  end

  def feature
    @feature ||= stub("feature").tap do |feature|
      document = stub("document", published_edition: stub("published_edition"))
      feature.stubs(:document).returns(document)
    end
  end

  def stub_feature_list(feature_count = 1)
    published_features = stub("published editions")
    published_features.stubs(:count).returns(feature_count)
    features = Array.new(feature_count) { feature }
    published_features.stubs(:limit).with(5).returns(features[0..5])
    stub("feature list", current: published_features)
  end
end
