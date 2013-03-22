require 'test_helper'

class Admin::FeaturesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  test "get :new loads the given edition" do
    country = create(:country)
    feature_list = create(:feature_list, featurable: country, locale: :en)
    edition = create(:published_speech, world_locations: [country])

    get :new, feature_list_id: feature_list, edition_id: edition.id

    assert_equal edition.document, assigns[:feature].document
  end

  test "get :new does not load an edition if its not in the featureable editions of the feature list" do
    country = create(:country)
    feature_list = create(:feature_list, featurable: country, locale: :en)
    edition = create(:published_speech)

    assert_raises ActiveRecord::RecordNotFound do
      get :new, feature_list_id: feature_list, edition_id: edition.id
    end
  end

  test "post :unfeature sets the ended_at date of a feature" do
    country = create(:country)
    feature_list = create(:feature_list, featurable: country, locale: :en)
    edition = create(:published_speech)
    feature = create(:feature, document: edition.document, feature_list: feature_list)

    post :unfeature, feature_list_id: feature_list, id: feature

    feature.reload

    assert_equal Time.zone.now, feature.ended_at
  end
end