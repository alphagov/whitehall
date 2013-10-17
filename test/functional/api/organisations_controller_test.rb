require 'test_helper'

class Api::OrganisationsControllerTest < ActionController::TestCase
  disable_database_queries
  should_be_a_public_facing_controller

  view_test "show responds with JSON representation of found organisation" do
    organisation = stub_record(:organisation, slug: 'meh')
    organisation.stubs(:to_param).returns('meh')
    Organisation.stubs(:find_by_slug).with(organisation.slug).returns(organisation)
    presenter = Api::OrganisationPresenter.new(organisation, controller.view_context)
    presenter.stubs(:as_json).returns(foo: :bar)
    Api::OrganisationPresenter.stubs(:new).with(organisation, anything).returns(presenter)

    get :show, id: organisation.slug, format: 'json'
    assert_equal 'bar', json_response['foo']
  end

  view_test "show includes _response_info in response" do
    organisation = stub_record(:organisation, slug: 'meh')
    organisation.stubs(:to_param).returns('meh')
    Organisation.stubs(:find_by_slug).with(organisation.slug).returns(organisation)
    presenter = Api::OrganisationPresenter.new(organisation, controller.view_context)
    presenter.stubs(:as_json).returns(foo: :bar)
    Api::OrganisationPresenter.stubs(:new).with(organisation, anything).returns(presenter)

    get :show, id: organisation.slug, format: 'json'
    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "show responds with 404 if organisation is not found" do
    Organisation.stubs(:find_by_slug).with('unknown').returns nil
    get :show, id: 'unknown', format: 'json'
    assert_response :not_found
    assert_equal 'not found', json_response['_response_info']['status']
  end

  view_test "index paginates organisations" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)

    orgs_includes = stub
    orgs_includes.stubs(:order).returns([])
    Organisation.stubs(:includes).returns(orgs_includes)

    Api::OrganisationPresenter.stubs(:paginate).with(Organisation.includes(:parent_organisations, :child_organisations, :translations).order(:id), anything).returns(presenter)

    get :index, format: 'json'

    assert_equal 'representation', json_response['paged']
  end

  view_test "index includes _response_info in response" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)

    orgs_includes = stub
    orgs_includes.stubs(:order).returns([])
    Organisation.stubs(:includes).returns(orgs_includes)

    Api::OrganisationPresenter.stubs(:paginate).with(Organisation.includes(:parent_organisations, :child_organisations, :translations).order(:id), anything).returns(presenter)

    get :index, format: 'json'

    assert_equal 'ok', json_response['_response_info']['status']
  end
end
