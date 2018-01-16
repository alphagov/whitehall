require 'test_helper'

class Admin::FeatureListsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  test "get show redirects to the featurable features page" do
    world_location = create(:world_location)
    feature_list = create(:feature_list, featurable: world_location, locale: :fr)

    get :show, params: { id: feature_list }

    assert_redirected_to features_admin_world_location_path(feature_list.featurable, locale: feature_list.locale)
  end

  test "post reorder reorders the feature list" do
    world_location = create(:world_location)
    feature_list = create(:feature_list, featurable: world_location, locale: :fr)
    feature_1 = create(:feature, feature_list: feature_list, ordering: 1)
    feature_2 = create(:feature, feature_list: feature_list, ordering: 2)

    post :reorder, params: { id: feature_list, ordering: {
      feature_2.id.to_s => "1",
      feature_1.id.to_s => "2"
    } }

    assert_equal [feature_2, feature_1], feature_list.reload.features
  end

  test "post reorder with no ordering does nothing" do
    world_location = create(:world_location)
    feature_list = create(:feature_list, featurable: world_location, locale: :fr)

    post :reorder, params: { id: feature_list }

    assert_redirected_to features_admin_world_location_path(feature_list.featurable, locale: feature_list.locale)
  end
end
