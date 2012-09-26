require 'test_helper'

class Api::DetailedGuidesControllerTest < ActionController::TestCase
  disable_database_queries
  should_be_a_public_facing_controller

  test "show responds with JSON representation of found guide" do
    detailed_guide = stub_edition(:detailed_guide)
    DetailedGuide.stubs(:published_as).with(detailed_guide.slug).returns(detailed_guide)
    presenter = Api::DetailedGuidePresenter.decorate(detailed_guide)
    presenter.stubs(:as_json).returns(guide: :representation)
    Api::DetailedGuidePresenter.stubs(:new).with(detailed_guide).returns(presenter)

    get :show, id: detailed_guide.slug, format: 'json'
    assert_equal 'representation', json_response['guide']
  end

  test "show includes _response_info in response" do
    detailed_guide = stub_edition(:detailed_guide)
    DetailedGuide.stubs(:published_as).with(detailed_guide.slug).returns(detailed_guide)
    presenter = Api::DetailedGuidePresenter.decorate(detailed_guide)
    presenter.stubs(:as_json).returns(json: :representation)
    Api::DetailedGuidePresenter.stubs(:new).with(detailed_guide).returns(presenter)

    get :show, id: detailed_guide.slug, format: 'json'
    assert_equal({'status' => 'ok'}, json_response['_response_info'])
  end

  test "show responds with 404 if published guide not found" do
    DetailedGuide.stubs(:published_as).returns(nil)
    get :show, id: 'unknown', format: 'json'
    assert_response :not_found
    assert_equal({'status' => 'not found'}, json_response['_response_info'])
  end

  test "index paginates published detailed guides" do
    presenter = Api::DetailedGuidePresenter::PagePresenter.new([])
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::DetailedGuidePresenter.stubs(:paginate).with(DetailedGuide.published.alphabetical).returns(presenter)

    get :index, format: 'json'

    assert_equal 'representation', json_response['paged']
  end

  test "index includes _response_info in response" do
    presenter = Api::DetailedGuidePresenter::PagePresenter.new([])
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::DetailedGuidePresenter.stubs(:paginate).with(DetailedGuide.published.alphabetical).returns(presenter)

    get :index, format: 'json'

    assert_equal({'status' => 'ok'}, json_response['_response_info'])
  end

  private

  def json_response
    ActiveSupport::JSON.decode(response.body)
  end
end
