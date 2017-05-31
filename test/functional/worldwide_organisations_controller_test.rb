require "test_helper"

class WorldwideOrganisationsControllerTest < ActionController::TestCase
  include GovukAbTesting::MinitestHelpers
  should_be_a_public_facing_controller
  include GovukAbTesting::MinitestHelpers

  test "shows worldwide organisation information" do
    organisation = create(:worldwide_organisation)
    get :show, id: organisation.id
    assert_equal organisation, assigns(:worldwide_organisation)
  end

  test "sets meta description" do
    organisation = create(:worldwide_organisation)
    create(:about_corporate_information_page, organisation: nil, worldwide_organisation: organisation, summary: 'my summary')

    get :show, id: organisation.id

    assert_equal 'my summary', assigns(:meta_description)
  end

  test "should populate slimmer organisations header with worldwide organisation and its sponsored organisations" do
    organisation = create(:worldwide_organisation, :translated, :with_sponsorships)
    sponsoring_organisation = organisation.sponsoring_organisations.first

    get :show, id: organisation.id

    expected_header_value = "<#{organisation.analytics_identifier}><#{sponsoring_organisation.analytics_identifier}>"
    assert_equal expected_header_value, response.headers["X-Slimmer-Organisations"]
  end

  test "should set slimmer worldwide locations header" do
    world_location = create(:world_location)
    organisation = create(:worldwide_organisation, world_locations: [world_location])

    get :show, id: organisation.id

    assert_equal "<#{world_location.analytics_identifier}>", response.headers["X-Slimmer-World-Locations"]
  end

  view_test "shows links to associated world locations" do
    location_1 = create(:world_location)
    location_2 = create(:world_location)
    organisation = create(:worldwide_organisation, world_locations: [location_1, location_2])

    get :show, id: organisation.id

    assert_select "a[href='#{world_location_path(location_1)}']"
    assert_select "a[href='#{world_location_path(location_2)}']"
  end

  test "show redirects to the api worldwide organisation endpoint when json is requested" do
    organisation = create(:worldwide_organisation)
    get :show, id: organisation.id, format: :json
    assert_redirected_to api_worldwide_organisation_path(organisation, format: :json)
  end

  view_test "showing an organisation without a list of contacts doesn't try to create one" do
    # needs to be a view_test so the entire view is rendered
    worldwide_organisation = create(:worldwide_organisation)
    worldwide_organisation.main_office = create(:worldwide_office, worldwide_organisation: worldwide_organisation)
    get :show, id: worldwide_organisation

    worldwide_organisation.reload
    refute worldwide_organisation.has_home_page_offices_list?
  end

  test "show redirects users in the b group to /government/world/<location>" do
    location_under_test_slug = "india"
    world_location = create(:world_location, slug: location_under_test_slug)
    worldwide_organisation = create(:worldwide_organisation,
                                    slug: "british-high-commission-new-delhi",
                                    world_locations: [world_location])
    with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
      get :show, id: worldwide_organisation
      assert_redirected_to world_location_path(world_location)
    end
  end

  test "show doesn't redirect A group users" do
    world_location = create(:world_location)
    worldwide_organisation = create(:worldwide_organisation, world_locations: [world_location])
    with_variant WorldwidePublishingTaxonomy: "A", assert_meta_tag: false do
      get :show, id: worldwide_organisation
      assert_response :ok
    end
  end

  test "show doesn't redirect B group users for countries that aren't in the test" do
    location_not_under_test_slug = "germany"
    world_location = create(:world_location, slug: location_not_under_test_slug)
    worldwide_organisation = create(:worldwide_organisation, world_locations: [world_location])
    with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
      get :show, id: worldwide_organisation
      assert_response :ok
    end
  end

  test "show doesn't redirect B group users for organisations that aren't in the test" do
    location_under_test_slug = "usa"
    world_location = create(:world_location, slug: location_under_test_slug)

    org_not_under_test_slug = "emerging-risks-directorate"
    worldwide_organisation = create(:worldwide_organisation,
                                    slug: org_not_under_test_slug,
                                    world_locations: [world_location])

    with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
      get :show, id: worldwide_organisation
      assert_response :ok
    end
  end

  test "show doesn't redirect B group users if they are viewing a non-en locale" do
    location_under_test_slug = "india"
    world_location = create(:world_location, slug: location_under_test_slug)
    worldwide_organisation = create(:worldwide_organisation, world_locations: [world_location])

    LocalisedModel.new(worldwide_organisation, :fr)
      .update_attributes(name: "Le embassy de india")

    with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
      get :show, id: worldwide_organisation, locale: "fr"
      assert_response :ok
    end
  end

  test "show redirects B group users to their hardcoded location page if present" do
    world_location = create(:world_location)

    hard_coded_redirects = {
      "british-high-commission-pretoria" => "south-africa",
      "british-consulate-general-los-angeles" => "usa",
      "did-south-africa" => "south-africa",
      "british-deputy-high-commission-kolkata" => "india",
      "uk-science-and-innovation-network" => "australia",
    }

    hard_coded_redirects.each do |organisation_slug, location_slug|
      hard_coded_location = create(:world_location, slug: location_slug)
      worldwide_organisation = create(
        :worldwide_organisation,
        slug: organisation_slug,
        world_locations: [
          world_location,
          hard_coded_location,
        ]
      )

      with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
        get :show, id: worldwide_organisation
        assert_redirected_to world_location_path(hard_coded_location)
      end
    end
  end

  test "should redirect to the worldwide_organisation if the user is in the 'A' cohort" do
    with_variant WorldwidePublishingTaxonomy: "A", assert_meta_tag: false do
      organisation = create(:worldwide_organisation)
      world_location = create(:world_location)

      get :show_b_variant, id: organisation.id, world_location_id: world_location.id

      assert_redirected_to worldwide_organisation_path(organisation)
    end
  end

  test "should redirect to the worldwide_organisation page if the user is in the B cohort but the world_location is not in the test data" do
    with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
      organisation = create(:worldwide_organisation)
      world_location = create(:world_location)
      WorldwideAbTestHelper.any_instance.expects(:has_content_for?).returns(nil)

      get :show_b_variant, id: organisation.id, world_location_id: world_location.id

      assert_redirected_to worldwide_organisation_path(organisation)
    end
  end

  test "should redirect to the worldwide_organisation page for B cohort but the world_organisation is not in the test data" do
    with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
      worldwide_organisation = create(:worldwide_organisation, slug: "not-an-embassy")
      world_location = create(:world_location)

      data = {
        "embassies" => {}
      }
      WorldwideAbTestHelper.any_instance.stubs(:has_content_for?).returns(true)
      WorldwideAbTestHelper.any_instance.expects(:content_for).with(world_location.slug).at_least_once.returns(data)
      get :show_b_variant, id: worldwide_organisation.slug, world_location_id: world_location.slug

      assert_redirected_to worldwide_organisation_path(worldwide_organisation)
    end
  end

  test "should return 200 if in the B cohort and there is data" do
    with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
      worldwide_organisation = create(:worldwide_organisation)
      world_location = create(:world_location)

      data = sample_yaml(worldwide_organisation)
      WorldwideAbTestHelper.any_instance.stubs(:has_content_for?).returns(true)
      WorldwideAbTestHelper.any_instance.expects(:content_for).with(world_location.slug).at_least_once.returns(data)
      get :show_b_variant, id: worldwide_organisation.slug, world_location_id: world_location.slug

      assert_response 200
    end
  end

  test "redirects out of the B cohort if the request for an embassy page is non en" do
    with_variant WorldwidePublishingTaxonomy: "B", assert_meta_tag: false do
      worldwide_organisation = create(:worldwide_organisation)
      LocalisedModel.new(worldwide_organisation, "fr").update_attributes(name: "Le nom de Org")
      world_location = create(:world_location)
      LocalisedModel.new(world_location, "fr").update_attributes(name: "Le location")

      data = sample_yaml(worldwide_organisation)
      WorldwideAbTestHelper.any_instance.stubs(:has_content_for?).returns(true)
      WorldwideAbTestHelper.any_instance.expects(:content_for).with(world_location.slug).at_least_once.returns(data)
      get :show_b_variant, id: worldwide_organisation.slug, world_location_id: world_location.slug, locale: :fr

      assert_redirected_to worldwide_organisation_path(
        worldwide_organisation,
        "ABTest-WorldwidePublishingTaxonomy" => "A",
        locale: :fr,
      )
    end
  end

  def sample_yaml(worldwide_organisation)
    {
      "embassies" => {
        worldwide_organisation.slug => [
          {
            "title" => "British High Commission Sample City",
            "summary" => "Summary",
            "body" => "The Body"
          }
        ]
      }
    }
  end
end
