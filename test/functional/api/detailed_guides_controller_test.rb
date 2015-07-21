require 'test_helper'

class Api::DetailedGuidesControllerTest < ActionController::TestCase
  disable_database_queries
  should_be_a_public_facing_controller

  view_test "show responds with JSON representation of found guide" do
    organisation = stub_record(:organisation, organisation_type: OrganisationType.ministerial_department)
    detailed_guide = stub_edition(:detailed_guide, organisations: [organisation])
    DetailedGuide.stubs(:published_as).with(detailed_guide.slug).returns(detailed_guide)
    presenter = Api::DetailedGuidePresenter.new(detailed_guide, controller.view_context)
    presenter.stubs(:as_json).returns(guide: :representation)
    Api::DetailedGuidePresenter.stubs(:new).with(detailed_guide, anything).returns(presenter)

    get :show, id: detailed_guide.slug, format: 'json'
    assert_equal 'representation', json_response['guide']
  end

  view_test "show includes _response_info in response" do
    organisation = stub_record(:organisation, organisation_type: OrganisationType.ministerial_department)
    detailed_guide = stub_edition(:detailed_guide, organisations: [organisation])
    DetailedGuide.stubs(:published_as).with(detailed_guide.slug).returns(detailed_guide)
    presenter = Api::DetailedGuidePresenter.new(detailed_guide, controller.view_context)
    presenter.stubs(:as_json).returns(guide: :representation)
    Api::DetailedGuidePresenter.stubs(:new).with(detailed_guide, anything).returns(presenter)

    get :show, id: detailed_guide.slug, format: 'json'
    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "show responds with 404 if published guide not found" do
    DetailedGuide.stubs(:published_as).returns(nil)
    get :show, id: 'unknown', format: 'json'
    assert_response :not_found
    assert_equal 'not found', json_response['_response_info']['status']
  end

  view_test "index paginates published detailed guides" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::DetailedGuidePresenter.stubs(:paginate).with(DetailedGuide.published.alphabetical, anything).returns(presenter)

    get :index, format: 'json'

    assert_equal 'representation', json_response['paged']
  end

  view_test "index includes _response_info in response" do
    presenter = Api::PagePresenter.new(Kaminari.paginate_array([]).page(1).per(1), controller.view_context)
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::DetailedGuidePresenter.stubs(:paginate).with(DetailedGuide.published.alphabetical, anything).returns(presenter)

    get :index, format: 'json'

    assert_equal 'ok', json_response['_response_info']['status']
  end
end
