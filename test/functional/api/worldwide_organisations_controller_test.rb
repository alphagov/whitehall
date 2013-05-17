require 'test_helper'

class Api::WorldwideOrganisationsControllerTest < ActionController::TestCase
  disable_database_queries
  should_be_a_public_facing_controller

  view_test "show responds with JSON representation of found world location" do
    worldwide_organisation = stub_record(:worldwide_organisation, slug: 'woo')
    worldwide_organisation.stubs(:to_param).returns('woo')
    WorldwideOrganisation.stubs(:find_by_slug).with(worldwide_organisation.slug).returns(worldwide_organisation)

    presenter = Api::WorldwideOrganisationPresenter.new(worldwide_organisation, controller.view_context)
    presenter.stubs(:as_json).returns(worldwide_organisation: :representation)
    Api::WorldwideOrganisationPresenter.stubs(:new).with(worldwide_organisation, anything).returns(presenter)

    get :show, id: worldwide_organisation.slug, format: 'json'
    assert_equal 'representation', json_response['worldwide_organisation']
  end

  view_test "show includes _response_info in response" do
    worldwide_organisation = stub_record(:worldwide_organisation, slug: 'woo')
    worldwide_organisation.stubs(:to_param).returns('woo')
    WorldwideOrganisation.stubs(:find_by_slug).with(worldwide_organisation.slug).returns(worldwide_organisation)

    presenter = Api::WorldwideOrganisationPresenter.new(worldwide_organisation, controller.view_context)
    presenter.stubs(:as_json).returns(worldwide_organisation: :representation)
    Api::WorldwideOrganisationPresenter.stubs(:new).with(worldwide_organisation, anything).returns(presenter)

    get :show, id: worldwide_organisation.slug, format: 'json'
    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "show responds with 404 if org is not found" do
    WorldwideOrganisation.stubs(:find_by_slug).with('unknown').returns nil

    get :show, id: 'unknown', format: 'json'
    assert_response :not_found
    assert_equal 'not found', json_response['_response_info']['status']
  end

  view_test "index paginates worldwide organisations for the supplied location" do
    world_location = stub_record(:world_location, slug: 'meh')
    world_location.stubs(:worldwide_organisations).returns ['my orgs']
    WorldLocation.stubs(:find_by_slug).with(world_location.slug).returns(world_location)

    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::WorldwideOrganisationPresenter.stubs(:paginate).with(world_location.worldwide_organisations, anything).returns(presenter)

    get :index, world_location_id: world_location.slug, format: 'json'

    assert_equal 'representation', json_response['paged']
  end

  view_test "index includes _response_info in response" do
    world_location = stub_record(:world_location, slug: 'meh')
    world_location.stubs(:worldwide_organisations).returns ['my orgs']
    WorldLocation.stubs(:find_by_slug).with(world_location.slug).returns(world_location)

    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::WorldwideOrganisationPresenter.stubs(:paginate).with(world_location.worldwide_organisations, anything).returns(presenter)

    get :index, world_location_id: world_location.slug, format: 'json'

    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "index responds with 404 if location not found" do
    WorldLocation.stubs(:find_by_slug).with('unknown').returns nil
    get :index, world_location_id: 'unknown', format: 'json'
    assert_response :not_found
    assert_equal 'not found', json_response['_response_info']['status']
  end

  private

  def json_response
    ActiveSupport::JSON.decode(response.body)
  end
end
