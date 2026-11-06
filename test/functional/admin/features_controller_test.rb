require "test_helper"

class Admin::FeaturesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  test "get :new loads the given edition" do
    world_location_news = build(:world_location_news)
    world_location = create(:world_location, world_location_news:)
    feature_list = create(:feature_list, featurable: world_location_news, locale: :en)
    edition = create(:published_speech, world_locations: [world_location])

    get :new, params: { feature_list_id: feature_list, edition_id: edition.id }

    assert_equal edition.document, assigns[:feature].document
  end

  test "post :unfeature ends the feature" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:)
    feature_list = create(:feature_list, featurable: world_location_news, locale: :en)
    edition = create(:published_speech)
    feature = create(:feature, document: edition.document, feature_list:)

    post :unfeature, params: { feature_list_id: feature_list, id: feature }

    feature.reload

    assert_equal Time.zone.now, feature.ended_at
  end

  test "post :unfeature republishes the organisation when the featurable is an organisation" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    edition = create(:published_speech)
    feature = create(:feature, document: edition.document, feature_list:)

    Whitehall::PublishingApi.expects(:republish_async).with(organisation).once

    post :unfeature, params: { feature_list_id: feature_list, id: feature }
  end

  test "post :unfeature republishes the world location news when the featurable is a world location news" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:)
    feature_list = create(:feature_list, featurable: world_location_news, locale: :en)
    edition = create(:published_speech)
    feature = create(:feature, document: edition.document, feature_list:)

    Whitehall::PublishingApi.expects(:republish_async).with(world_location_news).once

    post :unfeature, params: { feature_list_id: feature_list, id: feature }
  end

  test "post :feature creates a feature and republishes the document & organisation when the featurable is an organisation" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    edition = create(:published_speech)

    params = {
      document_id: edition.document_id,
      image_attributes: {
        file: upload_fixture("images/960x640_gif.gif"),
      },
      alt_text: "some text",
    }

    PublishingApiDocumentRepublishingJob.expects(:perform_async).with(edition.document_id, false)
    Whitehall::PublishingApi.expects(:republish_async).with(organisation).once

    post :create, params: { feature_list_id: feature_list.id, feature: params }

    assert_equal edition.document_id, Feature.last.document_id
    assert_equal "960x640_gif.gif", Feature.last.image.filename
  end

  test "post :feature creates a feature and republishes the document & world location news when the featurable is an world location news" do
    world_location_news = build(:world_location_news)
    create(:world_location, world_location_news:)
    feature_list = create(:feature_list, featurable: world_location_news, locale: :en)
    edition = create(:published_speech)

    params = {
      document_id: edition.document_id,
      image_attributes: {
        file: upload_fixture("images/960x640_gif.gif"),
      },
      alt_text: "some text",
    }

    PublishingApiDocumentRepublishingJob.expects(:perform_async).with(edition.document_id, false)
    Whitehall::PublishingApi.expects(:republish_async).with(world_location_news).once

    post :create, params: { feature_list_id: feature_list.id, feature: params }

    assert_equal edition.document_id, Feature.last.document_id
    assert_equal "960x640_gif.gif", Feature.last.image.filename
  end

  view_test "get :edit shows the current image and alt text" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:, alt_text: "old alt text")

    get :edit, params: { feature_list_id: feature_list, id: feature }

    assert_response :success
    assert_select "img[src='#{feature.image.url}']"
    assert_select "input[name='feature[image_attributes][id]'][value='#{feature.image.id}']"
    assert_select "input[name='feature[image_attributes][file]'][type=file]"
    assert_select "input[name='feature[alt_text]'][value='old alt text']"
  end

  test "put :update replaces the image and alt text, and republishes the organisation" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:, alt_text: "old alt text")
    image = feature.image

    Whitehall::PublishingApi.expects(:republish_async).with(organisation).once

    put :update, params: {
      feature_list_id: feature_list,
      id: feature,
      feature: {
        alt_text: "new alt text",
        image_attributes: { id: image.id, file: upload_fixture("images/960x640_jpeg.jpg") },
      },
    }

    assert_redirected_to admin_feature_list_path(feature_list)
    feature.reload
    assert_equal image.id, feature.image.id
    assert_equal "960x640_jpeg.jpg", feature.image.filename
    assert_equal "new alt text", feature.alt_text
  end

  test "put :update keeps the existing image when no new file is given" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:)
    original_filename = feature.image.filename

    put :update, params: {
      feature_list_id: feature_list,
      id: feature,
      feature: { alt_text: "new alt text", image_attributes: { id: feature.image.id, file: "" } },
    }

    assert_redirected_to admin_feature_list_path(feature_list)
    assert_equal original_filename, feature.reload.image.filename
    assert_equal "new alt text", feature.alt_text
  end

  test "put :update uses an image cached from a previous failed submission when no new file is given" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:)
    cached_image = build(:featured_image_data, file: upload_fixture("big-cheese.960x640.jpg", "image/jpg"))

    put :update, params: {
      feature_list_id: feature_list,
      id: feature,
      feature: { image_attributes: { id: feature.image.id, file: "", file_cache: cached_image.file_cache } },
    }

    assert_redirected_to admin_feature_list_path(feature_list)
    assert_equal "big-cheese.960x640.jpg", feature.reload.image.filename
  end

  test "put :update discards a cached image if a new file is given" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:)
    cached_image = build(:featured_image_data, file: upload_fixture("big-cheese.960x640.jpg", "image/jpg"))

    AssetManagerCreateAssetJob.expects(:perform_async).with(regexp_matches(/960x640_jpeg/), anything).at_least_once
    AssetManagerCreateAssetJob.expects(:perform_async).with(regexp_matches(/big-cheese/), anything).never

    put :update, params: {
      feature_list_id: feature_list,
      id: feature,
      feature: {
        image_attributes: {
          id: feature.image.id,
          file: upload_fixture("images/960x640_jpeg.jpg"),
          file_cache: cached_image.file_cache,
        },
      },
    }

    assert_redirected_to admin_feature_list_path(feature_list)
    assert_equal "960x640_jpeg.jpg", feature.reload.image.filename
  end

  view_test "put :update re-renders the form when the new image is invalid" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:)
    original_filename = feature.image.filename

    put :update, params: {
      feature_list_id: feature_list,
      id: feature,
      feature: { image_attributes: { id: feature.image.id, file: upload_fixture("images/50x33_gif.gif") } },
    }

    assert_template :edit
    assert_select ".govuk-error-summary li", "Image file is too small. Select an image that is 960 pixels wide and 640 pixels tall."
    # The invalid image is rejected before it is cached, so there is nothing to resubmit
    assert_nil assigns(:feature).image.file_cache
    assert_equal original_filename, feature.reload.image.filename
  end

  test "put :update cannot change what is being featured" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:)
    original_document_id = feature.document_id

    assert_raises(ActionController::UnpermittedParameters) do
      put :update, params: {
        feature_list_id: feature_list,
        id: feature,
        feature: { document_id: create(:published_speech).document_id },
      }
    end

    assert_equal original_document_id, feature.reload.document_id
  end

  test "post :feature fails to save if the featurable is in a non-draft state" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    feature_list = build(:feature_list, locale: :en)
    _featurable_edition = create(:published_standard_edition, configurable_document_type: "test_type", feature_lists: [feature_list])
    edition_to_feature = create(:call_for_evidence)

    post :create, params: { feature_list_id: feature_list.id, feature: { document_id: edition_to_feature.document_id } }

    assert_response :forbidden
  end

  test "post :unfeature fails to save if the featurable is in a non-draft state" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    feature_list = build(:feature_list, locale: :en)
    _featurable_edition = create(:published_standard_edition, configurable_document_type: "test_type", feature_lists: [feature_list])
    featured_edition = create(:call_for_evidence)

    feature = create(:feature, document: featured_edition.document, feature_list:)

    post :unfeature, params: { feature_list_id: feature_list.id, id: feature }

    assert_response :forbidden
  end

  test "post :create is forbidden for users outside the organisation" do
    organisation = create(:organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    edition = create(:published_speech)

    post :create, params: { feature_list_id: feature_list.id, feature: { document_id: edition.document_id, alt_text: "some text" } }

    assert_response :forbidden
    assert_empty feature_list.reload.features
  end

  test "post :unfeature is forbidden for users outside the organisation" do
    organisation = create(:organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    edition = create(:published_speech)
    feature = create(:feature, document: edition.document, feature_list:)

    post :unfeature, params: { feature_list_id: feature_list, id: feature }

    assert_response :forbidden
    assert_nil feature.reload.ended_at
  end

  test "get :new and :confirm_unfeature are forbidden for users outside the organisation" do
    organisation = create(:organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    edition = create(:published_speech)
    feature = create(:feature, document: edition.document, feature_list:)

    get :new, params: { feature_list_id: feature_list, edition_id: edition.id }
    assert_response :forbidden

    get :confirm_unfeature, params: { feature_list_id: feature_list, id: feature }
    assert_response :forbidden
  end

  test "get :edit and put :update are forbidden for users outside the organisation" do
    organisation = create(:organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:, alt_text: "old alt text")

    get :edit, params: { feature_list_id: feature_list, id: feature }
    assert_response :forbidden

    put :update, params: { feature_list_id: feature_list, id: feature, feature: { alt_text: "new alt text" } }
    assert_response :forbidden
    assert_equal "old alt text", feature.reload.alt_text
  end

  test "cannot edit or update a feature belonging to a different feature list" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    other_feature_list = create(:feature_list, featurable: create(:organisation), locale: :en)
    other_feature = create(:feature, document: create(:published_speech).document, feature_list: other_feature_list, alt_text: "old alt text")
    params = { feature_list_id: feature_list, id: other_feature }

    assert_raise(ActiveRecord::RecordNotFound) { get :edit, params: }
    assert_raise(ActiveRecord::RecordNotFound) do
      put :update, params: params.merge(feature: { alt_text: "Not allowed" })
    end

    assert_equal "old alt text", other_feature.reload.alt_text
  end

  test "put :update cannot replace an image belonging to another record" do
    organisation = create(:organisation)
    login_as(:writer, organisation)
    feature_list = create(:feature_list, featurable: organisation, locale: :en)
    feature = create(:feature, document: create(:published_speech).document, feature_list:)
    person = create(:person, :with_image)
    original_filename = person.image.filename

    assert_raise(ActiveRecord::RecordNotFound) do
      put :update, params: {
        feature_list_id: feature_list,
        id: feature,
        feature: { image_attributes: { id: person.image.id, file: upload_fixture("images/960x640_jpeg.jpg") } },
      }
    end

    assert_equal original_filename, person.image.reload.filename
    assert_equal person, person.image.reload.featured_imageable
  end

  test "put :update fails to save if the featurable is in a non-draft state" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    feature_list = build(:feature_list, locale: :en)
    _featurable_edition = create(:published_standard_edition, configurable_document_type: "test_type", feature_lists: [feature_list])
    feature = create(:feature, document: create(:call_for_evidence).document, feature_list:, alt_text: "old alt text")

    put :update, params: { feature_list_id: feature_list.id, id: feature, feature: { alt_text: "new alt text" } }

    assert_response :forbidden
    assert_equal "old alt text", feature.reload.alt_text
  end

  test "post :create and :unfeature are forbidden for users who cannot update the featurable edition" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    feature_list = build(:feature_list, locale: :en)
    create(:draft_standard_edition, :access_limited_by_organisations, configurable_document_type: "test_type", feature_lists: [feature_list])
    edition_to_feature = create(:published_publication)
    feature = create(:feature, document: create(:published_publication).document, feature_list:)

    post :create, params: { feature_list_id: feature_list.id, feature: { document_id: edition_to_feature.document_id } }
    assert_response :forbidden

    post :unfeature, params: { feature_list_id: feature_list.id, id: feature }
    assert_response :forbidden
    assert_nil feature.reload.ended_at

    put :update, params: { feature_list_id: feature_list.id, id: feature, feature: { alt_text: "Not allowed" } }
    assert_response :forbidden
    assert_nil feature.reload.alt_text
  end
end
