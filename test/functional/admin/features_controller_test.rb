require 'test_helper'

class Admin::FeaturesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  test "get :new loads the given edition" do
    world_location = create(:world_location)
    feature_list = create(:feature_list, featurable: world_location, locale: :en)
    edition = create(:published_speech, world_locations: [world_location])

    get :new, feature_list_id: feature_list, edition_id: edition.id

    assert_equal edition.document, assigns[:feature].document
  end

  test "post :unfeature ends the feature" do
    world_location = create(:world_location)
    feature_list = create(:feature_list, featurable: world_location, locale: :en)
    edition = create(:published_speech)
    feature = create(:feature, document: edition.document, feature_list: feature_list)

    post :unfeature, feature_list_id: feature_list, id: feature

    feature.reload

    assert_equal Time.zone.now, feature.ended_at
  end
end
