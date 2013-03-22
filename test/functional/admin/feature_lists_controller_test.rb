require 'test_helper'

class Admin::FeatureListsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  test "get show redirects to the featurable features page" do
    country = create(:country)
    feature_list = create(:feature_list, featurable: country, locale: :fr)

    get :show, id: feature_list

    assert_redirected_to admin_world_location_features_path(feature_list.featurable, locale: feature_list.locale)
  end

  test "post reorder reorders the feature list" do
    country = create(:country)
    feature_list = create(:feature_list, featurable: country, locale: :fr)
    feature1 = create(:feature, feature_list: feature_list, ordering: 1)
    feature2 = create(:feature, feature_list: feature_list, ordering: 2)

    post :reorder, id: feature_list, ordering: {
      feature2.id.to_s => "1",
      feature1.id.to_s => "2"
    }

    assert_equal [feature2, feature1], feature_list.reload.features
  end
end