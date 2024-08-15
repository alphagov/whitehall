require "test_helper"

class Admin::OrganisationsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller
  def example_organisation_attributes
    attributes_for(:organisation).except(:logo, :analytics_identifier)
  end

  test "GET on :index assigns all organisations in alphabetical order" do
    organisation2 = create(:organisation, name: "org 2")
    organisation1 = create(:organisation, name: "org 1")
    get :index

    assert_response :success
    assert_template :index
    assert_equal [organisation1, organisation2], assigns(:organisations)
  end

  test "GET on :new denied if not a gds admin" do
    login_as :writer
    get :new
    assert_response :forbidden
  end

  test "POST on :create denied if not a gds admin" do
    login_as :writer
    post :create, params: { organisation: {} }
    assert_response :forbidden
  end

  view_test "Link to create organisation does not show if not a gds admin" do
    login_as :writer
    get :index
    refute_select ".govuk-button", text: "Create new organisation"
  end

  view_test "Link to create organisation shows if a gds admin" do
    get :index
    assert_select ".govuk-button", text: "Create new organisation"
  end

  test "POST on :create saves the organisation and its associations" do
    attributes = example_organisation_attributes

    parent_org1 = create(:organisation)
    parent_org2 = create(:organisation)

    post :create,
         params: {
           organisation: attributes
                           .merge(
                             parent_organisation_ids: [parent_org1.id, parent_org2.id],
                             organisation_type_key: :executive_agency,
                             govuk_status: "exempt",
                             featured_links_attributes: {
                               "0" => {
                                 url: "http://www.gov.uk/mainstream/something",
                                 title: "Something on mainstream",
                               },
                             },
                           ),
         }

    assert_redirected_to admin_organisations_path
    assert_equal "Organisation created successfully.", flash[:notice]
    assert organisation = Organisation.last
    assert organisation.topical_event_organisations.map(&:ordering).all?(&:present?), "no ordering"
    assert_equal organisation.topical_event_organisations.map(&:ordering).sort, organisation.topical_event_organisations.map(&:ordering).uniq.sort
    assert organisation_top_task = organisation.featured_links.last
    assert_equal "http://www.gov.uk/mainstream/something", organisation_top_task.url
    assert_equal "Something on mainstream", organisation_top_task.title
    assert_same_elements [parent_org1, parent_org2], organisation.parent_organisations
    assert_equal OrganisationType.executive_agency, organisation.organisation_type
    assert_equal "exempt", organisation.govuk_status
  end

  test "POST :create can set a custom logo" do
    post :create,
         params: {
           organisation: example_organisation_attributes
                           .merge(
                             organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
                             logo: upload_fixture("logo.png", "image/png"),
                           ),
         }

    assert_match %r{logo.png}, Organisation.last.logo.file.filename
  end

  test "POST create can set number of important board members" do
    post :create,
         params: {
           organisation: example_organisation_attributes
                           .merge(important_board_members: 1),
         }

    assert_equal 1, Organisation.last.important_board_members
  end

  test "POST on :create with invalid data re-renders the new form" do
    attributes = example_organisation_attributes

    assert_no_difference("Organisation.count") do
      post :create, params: { organisation: attributes.merge(name: "") }
    end
    assert_response :success
    assert_template :new
  end

  test "GET on :show loads the organisation and renders the show template" do
    organisation = create(:organisation)
    get :show, params: { id: organisation }

    assert_response :success
    assert_template :show
  end

  view_test "GET on :show displays processing label if image assets are not available" do
    organisation = build(:organisation, :with_default_news_image)
    organisation.default_news_image.assets = []
    organisation.save!

    get :show, params: { id: organisation }

    assert_select "span[class='govuk-tag govuk-tag--green']", text: "Processing", count: 1
  end

  test "GET on :edit loads the organisation and renders the edit template" do
    organisation = create(:organisation)
    get :edit, params: { id: organisation }

    assert_response :success
    assert_template :edit
    assert_equal organisation, assigns(:organisation)
  end

  view_test "GET on :edit allows entry of important board members only data to Editors and above" do
    organisation = create(:organisation)
    junior_board_member_role = create(:board_member_role)
    senior_board_member_role = create(:board_member_role)

    create(:organisation_role, organisation:, role: senior_board_member_role)
    create(:organisation_role, organisation:, role: junior_board_member_role)

    managing_editor = create(:managing_editor, organisation:)
    departmental_editor = create(:departmental_editor, organisation:)
    world_editor = create(:world_editor, organisation:)

    get :edit, params: { id: organisation }
    assert_select "select#organisation_important_board_members option", count: 2

    login_as(departmental_editor)
    get :edit, params: { id: organisation }
    assert_select "select#organisation_important_board_members option", count: 2

    login_as(managing_editor)
    get :edit, params: { id: organisation }
    assert_select "select#organisation_important_board_members option", count: 2

    login_as(world_editor)
    get :edit, params: { id: organisation }
    assert_select "select#organisation_important_board_members option", count: 0
  end

  view_test "GET :edit renders hidden id field for default news image" do
    organisation = create(:organisation, :with_default_news_image)

    get :edit, params: { id: organisation }

    expected_hidden_field_name = "organisation[default_news_image_attributes][id]"
    expected_hidden_field_value = organisation.default_news_image.id
    assert_select "input[name='#{expected_hidden_field_name}'][value='#{expected_hidden_field_value}']"
  end

  view_test "GET :edit shows processing label if logo or default news image assets are not available" do
    organisation = build(:organisation, :with_default_news_image, :with_logo_and_assets)
    organisation.assets = []
    organisation.default_news_image.assets = []
    organisation.save!

    get :edit, params: { id: organisation }

    assert_select "span[class='govuk-tag govuk-tag--green']", text: "Processing", count: 2
  end

  test "PUT on :update allows updating of organisation role ordering" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role)
    organisation_role = create(:organisation_role, organisation:, role: ministerial_role, ordering: 1)

    put :update,
        params: { id: organisation.id,
                  organisation: { organisation_roles_attributes: {
                    "0" => { id: organisation_role.id, ordering: "2" },
                  } } }

    assert_equal 2, organisation_role.reload.ordering
  end

  test "PUT :update can set a custom logo" do
    organisation = create(:organisation)
    put :update,
        params: { id: organisation,
                  organisation: {
                    organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
                    logo: upload_fixture("logo.png"),
                  } }
    assert_match %r{logo.png}, organisation.reload.logo.file.filename
  end

  test "PUT :update cleans logo param when custom logo id is not passed to controller" do
    organisation = create(:organisation, organisation_logo_type_id: OrganisationLogoType::CustomLogo.id, logo: upload_fixture("logo.png"))
    put :update,
        params: { id: organisation,
                  organisation: {
                    organisation_logo_type_id: OrganisationLogoType::SingleIdentity.id,
                    logo: upload_fixture("logo.png"),
                  } }

    assert_nil organisation.reload.logo.file
  end

  test "PUT :update cleans the non_departmental_public_body params when org type is not a non_departmental_public_body" do
    organisation = create(:organisation, ocpa_regulated: true, public_meetings: true, public_minutes: true, regulatory_function: true)
    put :update,
        params: { id: organisation,
                  organisation: {
                    organisation_type_key: "executive_office",
                    ocpa_regulated: true,
                    public_meetings: true,
                    public_minutes: true,
                    regulatory_function: true,
                  } }

    assert_nil organisation.reload.ocpa_regulated
    assert_nil organisation.public_meetings
    assert_nil organisation.public_minutes
    assert_nil organisation.regulatory_function
  end

  test "PUT :update can set default news image" do
    organisation = create(:organisation)
    put :update,
        params: { id: organisation,
                  organisation: {
                    default_news_image_attributes: {
                      file: upload_fixture("minister-of-funk.960x640.jpg"),
                    },
                  } }
    assert_equal "minister-of-funk.960x640.jpg", organisation.reload.default_news_image.file.file.filename
  end

  test "PUT :update updates existing default news image" do
    organisation = create(:organisation, :with_default_news_image)
    default_news_image = organisation.default_news_image

    put :update,
        params: {
          id: organisation,
          organisation: {
            default_news_image_attributes: {
              id: default_news_image.id,
              file: upload_fixture("images/960x640_jpeg.jpg"),
            },
          },
        }

    assert_equal default_news_image.id, organisation.reload.default_news_image.id
    assert_equal "960x640_jpeg.jpg", organisation.reload.default_news_image.filename
  end

  test "PUT on :update with bad params does not update the organisation and renders the edit page" do
    ministerial_role = create(:ministerial_role)
    organisation = create(:organisation, name: "org name")
    create(:organisation_role, organisation:, role: ministerial_role)

    put :update, params: { id: organisation, organisation: { name: "" } }

    assert_response :success
    assert_template :edit

    assert_equal "org name", organisation.reload.name
  end

  test "PUT on :update should modify the organisation" do
    organisation = create(:organisation, name: "Ministry of Sound")
    organisation_attributes = {
      name: "Ministry of Noise",
    }

    put :update, params: { id: organisation, organisation: organisation_attributes }

    assert_redirected_to admin_organisation_path(organisation)
    assert_equal "Organisation updated successfully.", flash[:notice]
    organisation.reload
    assert_equal "Ministry of Noise", organisation.name
  end

  test "PUT on :update handles non-departmental public body information" do
    organisation = create(:organisation)

    put :update,
        params: { id: organisation,
                  organisation: {
                    ocpa_regulated: "false",
                    public_meetings: "true",
                    public_minutes: "true",
                    regulatory_function: "false",
                  } }

    organisation.reload

    assert_response :redirect
    assert_not organisation.ocpa_regulated?
    assert organisation.public_meetings?
    assert organisation.public_minutes?
    assert_not organisation.regulatory_function?
  end

  test "PUT on :update handles existing featured link attributes" do
    organisation = create(:organisation)
    featured_link = create(:featured_link, linkable: organisation)

    put :update,
        params: { id: organisation,
                  organisation: { featured_links_attributes: { "0" => {
                    id: featured_link.id,
                    title: "New title",
                    url: featured_link.url,
                    _destroy: "false",
                  } } } }

    assert_response :redirect
    assert_equal "New title", featured_link.reload.title
  end

  test "PUT on :update handles adding and removing topical event attributes" do
    topical_event_one = create(:topical_event)
    organisation = create(:organisation, topical_events: [topical_event_one])
    topical_event_two = create(:topical_event)

    put :update,
        params: {
          id: organisation,
          organisation: {
            topical_event_organisations_attributes: [
              {
                topical_event_id: topical_event_one.id,
                ordering: 0,
                id: organisation.topical_event_organisations.first.id,
                _destroy: "true",
              },
              {
                topical_event_id: topical_event_two.id,
                ordering: 1,
              },
            ],
          },
        }

    assert_response :redirect
    assert_equal [topical_event_two], organisation.reload.topical_events
  end

  test "GET on :show displays 'image is being processed' flash notice when not all image assets are uploaded" do
    organisation = build(:organisation, :with_default_news_image)
    organisation.default_news_image.assets = []
    organisation.save!

    get :show, params: { id: organisation }

    assert_match(/The image is being processed. Try refreshing the page./, flash[:notice])
  end

  view_test "Prevents unauthorized management of homepage priority" do
    organisation = create(:organisation)
    writer = create(:writer, organisation:)
    login_as(writer)

    get :edit, params: { id: organisation }
    refute_select "#organisation_homepage_type"

    managing_editor = create(:managing_editor, organisation:)
    login_as(managing_editor)
    get :edit, params: { id: organisation }
    assert_select "#organisation_homepage_type"

    gds_editor = create(:gds_editor, organisation:)
    login_as(gds_editor)
    get :edit, params: { id: organisation }
    assert_select "#organisation_homepage_type"
  end

  test "Non-admins can only edit their own organisations or children" do
    organisation1 = create(:organisation)
    gds_editor = create(:gds_editor, organisation: organisation1)
    login_as(gds_editor)

    get :edit, params: { id: organisation1 }
    assert_response :success

    organisation2 = create(:organisation)
    get :edit, params: { id: organisation2 }
    assert_response :forbidden

    organisation2.parent_organisations << organisation1
    get :edit, params: { id: organisation2 }
    assert_response :success
  end

  view_test "GET :features copes with topical events that have no dates" do
    topical_event = create(:topical_event)
    organisation = create(:organisation)
    feature_list = organisation.load_or_create_feature_list("en")
    feature_list.features.create!(
      topical_event:,
      image_attributes: {
        file: image_fixture_file,
      },
      alt_text: "Image alternative text",
    )

    get :features, params: { id: organisation, locale: "en" }
    assert_response :success
  end

  view_test "GET :features without an organisation defaults to the user organisation" do
    organisation = create(:organisation)

    get :features, params: { id: organisation, locale: "en" }
    assert_response :success

    selected_organisation = css_select('#organisation_filter option[selected="selected"]')
    assert_equal selected_organisation.text, organisation.name
  end

  view_test "GDS Editors can set political status" do
    organisation = create(:organisation)
    writer = create(:writer, organisation:)
    login_as(writer)

    get :edit, params: { id: organisation }
    refute_select "#organisation_political"

    managing_editor = create(:managing_editor, organisation:)
    login_as(managing_editor)
    get :edit, params: { id: organisation }
    refute_select "#organisation_political"

    gds_editor = create(:gds_editor, organisation:)
    login_as(gds_editor)
    get :edit, params: { id: organisation }
    assert_select "#organisation_political"
  end

  view_test "the featurables tab should display information regarding max documents" do
    first_feature = build(:feature, document: create(:published_case_study).document, ordering: 1)
    organisation = create(:organisation)
    create(:feature_list, locale: :en, featurable: organisation, features: [first_feature])
    get :features, params: { id: organisation }

    assert_match(/A maximum of 6 documents will be featured on GOV.UK.*/, response.body)
  end

  test "POST: create - discards logo cache if file is present" do
    filename = "logo.png"
    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/asset_manager_id", "name" => filename)
    cached_organisation = FactoryBot.build(:organisation_with_logo_and_assets)

    post :create,
         params: {
           organisation: example_organisation_attributes
                           .merge(
                             organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
                             logo_cache: cached_organisation.logo_cache,
                             logo: upload_fixture(filename, "image/png"),
                           ),
         }

    AssetManagerCreateAssetWorker.drain

    assert_equal 1, Organisation.last.assets.size
    assert_equal filename, Organisation.last.assets.first.filename
  end

  test "PUT: update - discards logo cache if file is present" do
    organisation = FactoryBot.create(
      :organisation_with_logo_and_assets,
      logo: upload_fixture("big-cheese.960x640.jpg", "image/png"),
    )

    replacement_filename = "logo.png"
    cached_filename = "minister-of-funk.960x640.jpg"
    Services.asset_manager.stubs(:create_asset).returns("id" => "http://asset-manager/assets/asset_manager_id", "name" => replacement_filename)
    cached_organisation = FactoryBot.build(
      :organisation_with_logo_and_assets,
      logo: upload_fixture(cached_filename, "image/png"),
    )

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{replacement_filename}/), anything, anything, anything, anything, anything).times(1)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{cached_filename}/), anything, anything, anything, anything, anything).never

    put :update,
        params: { id: organisation.id,
                  organisation: {
                    organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
                    logo: upload_fixture(replacement_filename, "image/png"),
                    logo_cache: cached_organisation.logo_cache,
                  } }

    AssetManagerCreateAssetWorker.drain

    assert_equal 1, Organisation.last.assets.size
    assert_equal replacement_filename, Organisation.last.assets.first.filename
  end

  test "POST: create - discards default news image cache if file is present" do
    filename = "big-cheese.960x640.jpg"
    cached_default_news_image = build(:featured_image_data)

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/minister-of-funk.960x640/), anything, anything, anything, anything, anything).never
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{filename}/), anything, anything, anything, anything, anything).times(7)

    post :create,
         params: example_organisation_attributes.merge({
           organisation: {
             name: "new",
             logo_formatted_name: "name",
             organisation_type_key: :executive_agency,
             default_news_image_attributes: {
               file: upload_fixture(filename, "image/png"),
               file_cache: cached_default_news_image.file_cache,
             },
           },
         })
  end

  test "PUT: update - discards default news image cache if file is present" do
    organisation = FactoryBot.create(:organisation_with_default_news_image)
    default_news_image = organisation.default_news_image

    replacement_filename = "example_fatality_notice_image.jpg"
    cached_filename = "big-cheese.960x640.jpg"
    cached_default_news_image = build(:featured_image_data, file: upload_fixture(cached_filename, "image/png"))

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{replacement_filename}/), anything, anything, anything, anything, anything).times(7)
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/#{cached_filename}/), anything, anything, anything, anything, anything).never

    put :update,
        params: {
          id: organisation.id,
          organisation: {
            default_news_image_attributes: {
              id: default_news_image.id,
              file: upload_fixture(replacement_filename, "image/png"),
              file_cache: cached_default_news_image.file_cache,
            },
          },
        }
  end
end
