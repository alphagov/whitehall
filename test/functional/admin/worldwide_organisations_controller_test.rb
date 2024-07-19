require "test_helper"

class Admin::WorldwideOrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  test "actions are forbidden when the editionable_worldwide_organisations feature flag is enabled" do
    feature_flags.switch! :editionable_worldwide_organisations, true
    worldwide_organisation = create(:worldwide_organisation)

    get :show, params: { id: worldwide_organisation.id }

    assert_response :forbidden
  end

  test "shows a list of worldwide organisations" do
    organisation = create(:worldwide_organisation)
    get :index
    assert_equal [organisation], assigns(:worldwide_organisations)
  end

  test "presents a form to create a new worldwide organisation" do
    get :new
    assert_template :new
    assert_kind_of WorldwideOrganisation, assigns(:worldwide_organisation)
  end

  test "creates a worldwide organisation" do
    post :create,
         params: {
           worldwide_organisation: {
             name: "Organisation",
           },
         }

    worldwide_organisation = WorldwideOrganisation.last
    assert_kind_of WorldwideOrganisation, worldwide_organisation
    assert_equal "Organisation created successfully.", flash[:notice]
    assert_equal "Organisation", worldwide_organisation.name

    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  view_test "shows validation errors on invalid worldwide organisation" do
    post :create,
         params: {
           worldwide_organisation: {
             name: "",
           },
         }

    assert_select ".govuk-error-summary"
  end

  test "shows an edit page for an existing worldwide organisation" do
    organisation = create(:worldwide_organisation)
    get :edit, params: { id: organisation.id }
  end

  view_test "GET :edit shows processing label if default news image assets are not available" do
    organisation = build(:worldwide_organisation, :with_default_news_image)
    organisation.default_news_image.assets = []
    organisation.save!

    get :edit, params: { id: organisation }

    assert_select "span[class='govuk-tag govuk-tag--green']", text: "Processing", count: 1
  end

  test "updates an existing objects with new values" do
    organisation = create(:worldwide_organisation)
    put :update,
        params: {
          id: organisation.id,
          worldwide_organisation: {
            name: "New name",
            default_news_image_attributes: {
              file: upload_fixture("minister-of-funk.960x640.jpg"),
            },
          },
        }
    worldwide_organisation = WorldwideOrganisation.last
    assert_equal "New name", worldwide_organisation.name
    assert_equal "minister-of-funk.960x640.jpg", worldwide_organisation.default_news_image.file.file.filename
    assert_equal "Organisation updated successfully.", flash[:notice]
    assert_redirected_to admin_worldwide_organisation_path(worldwide_organisation)
  end

  test "DELETE :destroys the WorldwideOrganisation and does not destroy dependent classes" do
    worldwide_organisation = create(:worldwide_organisation, :with_default_news_image)
    default_news_image_id = worldwide_organisation.default_news_image.id
    count = WorldwideOrganisation.count

    delete :destroy, params: { id: worldwide_organisation.id }

    assert_equal "Organisation deleted successfully", flash[:notice]
    assert_equal count - 1, WorldwideOrganisation.count
    assert_nil WorldwideOrganisation.find_by(id: worldwide_organisation.id)
    assert FeaturedImageData.find_by(id: default_news_image_id)
  end

  test "GET :confirm_destroy calls correctly" do
    organisation = create(:worldwide_organisation)

    get :confirm_destroy, params: { id: organisation.id }

    assert_response :success
  end

  test "GET :show calls correctly" do
    organisation = create(:worldwide_organisation, name: "Ministry of Silly Walks in Madrid")

    get :show, params: { id: organisation }

    assert_response :success
    assert_equal organisation, assigns(:worldwide_organisation)
  end

  view_test "GET on :show displays processing label if image assets are not available" do
    organisation = build(:worldwide_organisation, :with_default_news_image)
    organisation.default_news_image.assets = []
    organisation.save!

    get :show, params: { id: organisation }

    assert_select "span[class='govuk-tag govuk-tag--green']", text: "Processing", count: 1
    assert_match(/The image is being processed. Try refreshing the page./, flash[:notice])
  end

  test "PUT :update - discards default new organisation image cache if file is present " do
    worldwide_organisation = create(:worldwide_organisation, :with_default_news_image)
    replacement_filename = "example_fatality_notice_image.jpg"
    cached_filename = "big-cheese.960x640.jpg"
    cached_default_news_image = build(:featured_image_data, file: upload_fixture(cached_filename))

    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/asset_manager_id", "name" => replacement_filename)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{replacement_filename}/), anything, anything, anything, anything, anything).times(7)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{cached_filename}/), anything, anything, anything, anything, anything).never

    put :update,
        params: {
          id: worldwide_organisation.id,
          worldwide_organisation: {
            name: "New name",
            default_news_image_attributes: {
              file: upload_fixture(replacement_filename),
              file_cache: cached_default_news_image.file_cache,
              id: worldwide_organisation.default_news_image.id,
            },
          },
        }

    assert_equal replacement_filename, WorldwideOrganisation.last.default_news_image.filename
  end

  test "POST :create uses the file cache if present" do
    cached_filename = "big-cheese.960x640.jpg"
    cached_default_news_image = build(:featured_image_data, file: upload_fixture(cached_filename))

    post :create, params: {
      worldwide_organisation: {
        name: "name",
        default_news_image_attributes: {
          file_cache: cached_default_news_image.file_cache,
        },
      },
    }

    assert_equal cached_filename, WorldwideOrganisation.last.default_news_image.filename
  end

  test "PUT :update uses the file cache if present" do
    worldwide_organisation = create(:worldwide_organisation, :with_default_news_image)
    default_news_image_id = worldwide_organisation.default_news_image.id

    cached_filename = "big-cheese.960x640.jpg"
    cached_default_news_image = build(:featured_image_data, file: upload_fixture(cached_filename))

    put :update, params: {
      id: worldwide_organisation.id,
      worldwide_organisation: {
        default_news_image_attributes: {
          id: default_news_image_id,
          file_cache: cached_default_news_image.file_cache,
        },
      },
    }

    assert_equal cached_filename, worldwide_organisation.reload.default_news_image.filename
  end

  test "POST :create discards the file cache if file is present" do
    cached_filename = "big-cheese.960x640.jpg"
    cached_default_news_image = build(:featured_image_data, file: upload_fixture(cached_filename))
    replacement_filename = "example_fatality_notice_image.jpg"

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{cached_filename}/), anything, anything, anything, anything, anything).never
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{replacement_filename}/), anything, anything, anything, anything, anything).times(7)

    post :create, params: {
      worldwide_organisation: {
        name: "name",
        default_news_image_attributes: {
          file: upload_fixture(replacement_filename),
          file_cache: cached_default_news_image.file_cache,
        },
      },
    }

    assert_equal replacement_filename, WorldwideOrganisation.last.default_news_image.filename
  end

  test "PUT :update - updates existing default new image when image file is replaced" do
    worldwide_organisation = create(:worldwide_organisation, :with_default_news_image)
    default_news_image_id = worldwide_organisation.default_news_image.id

    put :update,
        params: {
          id: worldwide_organisation.id,
          worldwide_organisation: {
            name: "New name",
            default_news_image_attributes: {
              id: default_news_image_id,
              file: upload_fixture("minister-of-funk.960x640.jpg"),
            },
          },
        }

    worldwide_organisation = WorldwideOrganisation.last
    assert_equal "minister-of-funk.960x640.jpg", worldwide_organisation.default_news_image.file.file.filename
    assert_equal default_news_image_id, worldwide_organisation.default_news_image.id
  end
end
