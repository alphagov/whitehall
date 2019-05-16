require 'test_helper'

class Api::WorldLocationsControllerTest < ActionController::TestCase
  disable_database_queries
  should_be_a_public_facing_controller

  test "sets cache expiry to 30 minutes" do
    Api::WorldLocationsController.any_instance.stubs(:sorted_world_locations).returns([])

    get :index, format: 'json'

    assert_cache_control("max-age=#{Whitehall.default_api_cache_max_age}")
  end

  test "sets Access-Control-Allow-Origin to *" do
    Api::WorldLocationsController.any_instance.stubs(:sorted_world_locations).returns([])

    get :index, format: 'json'

    assert response.headers['Access-Control-Allow-Origin'] == '*'
  end

  view_test "show responds with JSON representation of found world location" do
    world_location = stub_record(:world_location, slug: 'meh')
    world_location.stubs(:to_param).returns('meh')
    WorldLocation.stubs(:find_by).with(slug: world_location.slug).returns(world_location)
    presenter = Api::WorldLocationPresenter.new(world_location, controller.view_context)
    presenter.stubs(:as_json).returns(location: :representation)
    Api::WorldLocationPresenter.stubs(:new).with(world_location, anything).returns(presenter)

    get :show, params: { id: world_location.slug }, format: 'json'
    assert_equal 'representation', json_response['location']
  end

  view_test "show includes _response_info in response" do
    world_location = stub_record(:world_location, slug: 'meh')
    world_location.stubs(:to_param).returns('meh')
    WorldLocation.stubs(:find_by).with(slug: world_location.slug).returns(world_location)
    presenter = Api::WorldLocationPresenter.new(world_location, controller.view_context)
    presenter.stubs(:as_json).returns(location: :representation)
    Api::WorldLocationPresenter.stubs(:new).with(world_location, anything).returns(presenter)

    get :show, params: { id: world_location.slug }, format: 'json'
    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "show responds with 404 if world location is not found" do
    WorldLocation.stubs(:find_by).with(slug: 'unknown').returns nil
    get :show, params: { id: 'unknown' }, format: 'json'
    assert_response :not_found
    assert_equal 'not found', json_response['_response_info']['status']
  end

  view_test "index paginates world locations" do
    Api::WorldLocationsController.any_instance.stubs(:sorted_world_locations).returns([])
    Api::PagePresenter.any_instance.stubs(:as_json).returns(paged: :representation)

    get :index, format: 'json'

    assert_equal 'representation', json_response['paged']
  end

  view_test "index includes _response_info in response" do
    Api::WorldLocationsController.any_instance.stubs(:sorted_world_locations).returns([])

    get :index, format: 'json'

    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "no world locations" do
    ActiveRecord::Base.connection.unstub(:select)
    get :index, format: 'json'
    assert_equal nil, json_response['next_page_url']
  end
end
