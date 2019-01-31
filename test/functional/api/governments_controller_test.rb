require 'test_helper'

class Api::GovernmentsControllerTest < ActionController::TestCase
  disable_database_queries
  should_be_a_public_facing_controller

  test "sets cache expiry to 30 minutes" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)

    Government.stubs(:order).returns([])
    Api::GovernmentPresenter.stubs(:paginate).with(Government.order(start_date: :desc), anything).returns(presenter)

    get :index, format: 'json'

    assert_cache_control("max-age=#{Whitehall.default_api_cache_max_age}")
  end

  test "sets Access-Control-Allow-Origin to *" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)

    Government.stubs(:order).returns([])
    Api::GovernmentPresenter.stubs(:paginate).with(Government.order(start_date: :desc), anything).returns(presenter)

    get :index, format: 'json'

    assert response.headers['Access-Control-Allow-Origin'] == '*'
  end

  view_test "index paginates governments" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)

    Government.stubs(:order).returns([])
    Api::GovernmentPresenter.stubs(:paginate).with(Government.order(start_date: :desc), anything).returns(presenter)

    get :index, format: 'json'

    assert_equal 'representation', json_response['paged']
  end

  view_test "index includes _response_info in response" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)

    Government.stubs(:order).returns([])
    Api::GovernmentPresenter.stubs(:paginate).with(Government.order(start_date: :desc), anything).returns(presenter)

    get :index, format: 'json'

    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "show responds with JSON representation of found government" do
    government = stub_record(:government, slug: 'old-gov')
    government.stubs(:to_param).returns('old-gov')
    Government.stubs(:find_by).with(slug: government.slug).returns(government)
    presenter = Api::GovernmentPresenter.new(government, controller.view_context)
    presenter.stubs(:as_json).returns(foo: :bar)
    Api::GovernmentPresenter.stubs(:new).with(government, anything).returns(presenter)

    get :show, params: { id: government.slug }, format: 'json'
    assert_equal 'bar', json_response['foo']
  end

  view_test "show includes _response_info in response" do
    government = stub_record(:government, slug: 'old-gov')
    government.stubs(:to_param).returns('old-gov')
    Government.stubs(:find_by).with(slug: government.slug).returns(government)
    presenter = Api::GovernmentPresenter.new(government, controller.view_context)
    presenter.stubs(:as_json).returns(foo: :bar)
    Api::GovernmentPresenter.stubs(:new).with(government, anything).returns(presenter)

    get :show, params: { id: government.slug }, format: 'json'
    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "show responds with 404 if government is not found" do
    Government.stubs(:find_by).with(slug: 'unknown').returns nil
    get :show, params: { id: 'unknown' }, format: 'json'
    assert_response :not_found
    assert_equal 'not found', json_response['_response_info']['status']
  end
end
