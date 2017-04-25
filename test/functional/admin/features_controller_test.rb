require 'test_helper'

class Admin::FeaturesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
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

  test "post :feature creates a feature and republishes the document" do
    organisation = create(:organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    edition = create(:published_speech)

    params = {
      document_id: edition.document_id,
      image: fixture_file_upload("images/960x640_gif.gif"),
      alt_text: "some text",
    }

    PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document_id)

    post :create, feature_list_id: feature_list.id, feature: params

    assert_equal edition.document_id, Feature.last.document_id
  end
end
