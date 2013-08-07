require 'test_helper'

class Api::WorldLocationsControllerTest < ActionController::TestCase
  disable_database_queries
  should_be_a_public_facing_controller

  view_test "show responds with JSON representation of found world location" do
    world_location = stub_record(:world_location, slug: 'meh')
    world_location.stubs(:to_param).returns('meh')
    WorldLocation.stubs(:find_by_slug).with(world_location.slug).returns(world_location)
    presenter = Api::WorldLocationPresenter.new(world_location, controller.view_context)
    presenter.stubs(:as_json).returns(location: :representation)
    Api::WorldLocationPresenter.stubs(:new).with(world_location, anything).returns(presenter)

    get :show, id: world_location.slug, format: 'json'
    assert_equal 'representation', json_response['location']
  end

  view_test "show includes _response_info in response" do
    world_location = stub_record(:world_location, slug: 'meh')
    world_location.stubs(:to_param).returns('meh')
    WorldLocation.stubs(:find_by_slug).with(world_location.slug).returns(world_location)
    presenter = Api::WorldLocationPresenter.new(world_location, controller.view_context)
    presenter.stubs(:as_json).returns(location: :representation)
    Api::WorldLocationPresenter.stubs(:new).with(world_location, anything).returns(presenter)

    get :show, id: world_location.slug, format: 'json'
    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "show responds with 404 if world location is not found" do
    WorldLocation.stubs(:find_by_slug).with('unknown').returns nil
    get :show, id: 'unknown', format: 'json'
    assert_response :not_found
    assert_equal 'not found', json_response['_response_info']['status']
  end

  view_test "index paginates world locations" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::WorldLocationPresenter.stubs(:paginate).with(WorldLocation.ordered_by_name, anything).returns(presenter)

    get :index, format: 'json'

    assert_equal 'representation', json_response['paged']
  end

  view_test "index includes _response_info in response" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::WorldLocationPresenter.stubs(:paginate).with(WorldLocation.ordered_by_name, anything).returns(presenter)

    get :index, format: 'json'

    assert_equal 'ok', json_response['_response_info']['status']
  end
end
