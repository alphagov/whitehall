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

  view_test "tags responds with JSON representation of found categories" do
    categories = [build(:mainstream_category, parent_tag: 'test1/test2', slug: 'category-1')]
    scope = stub('returned scope from with_published_content')
    MainstreamCategory.expects(:with_published_content).returns(scope)
    scope.expects(:where).with(parent_tag: 'test1/test2').returns(categories)
    presenter = Api::MainstreamCategoryTagPresenter.new(categories)

    get :tags, { parent_id: 'test1/test2', format: 'json' }
    assert_equal presenter.as_json[:results].to_json, json_response['results'].to_json
  end

  view_test "tags includes _response_info in response" do
    categories = [build(:mainstream_category, parent_tag: 'test1/test2', slug: 'category-1')]
    MainstreamCategory.stubs(:with_published_content).returns(stub('scope', where: categories))
    presenter = Api::MainstreamCategoryTagPresenter.new(categories)

    get :tags, { parent_id: 'test1/test2', format: 'json' }
    assert_equal 'ok', json_response['_response_info']['status']
  end

  view_test "tags responds with 404 if there aren't any valid children" do
    MainstreamCategory.stubs(:with_published_content).returns(stub('scope', where: []))
    get :tags, { parent_id: 'test1/test2', format: 'json' }
    assert_response :not_found
    assert_equal 'not found', json_response['_response_info']['status']
  end
end
