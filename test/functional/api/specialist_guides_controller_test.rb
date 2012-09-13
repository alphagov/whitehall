require 'test_helper'

class Api::SpecialistGuidesControllerTest < ActionController::TestCase
  disable_database_queries
  should_be_a_public_facing_controller

  test "show responds with JSON representation of found guide" do
    specialist_guide = stub_edition(:specialist_guide)
    SpecialistGuide.stubs(:published_as).with(specialist_guide.slug).returns(specialist_guide)
    presenter = Api::SpecialistGuidePresenter.decorate(specialist_guide)
    presenter.stubs(:as_json).returns(guide: :representation)
    Api::SpecialistGuidePresenter.stubs(:new).with(specialist_guide).returns(presenter)

    get :show, id: specialist_guide.slug, format: 'json'
    assert_equal 'representation', json_response['guide']
  end

  test "show includes _response_info in response" do
    specialist_guide = stub_edition(:specialist_guide)
    SpecialistGuide.stubs(:published_as).with(specialist_guide.slug).returns(specialist_guide)
    presenter = Api::SpecialistGuidePresenter.decorate(specialist_guide)
    presenter.stubs(:as_json).returns(json: :representation)
    Api::SpecialistGuidePresenter.stubs(:new).with(specialist_guide).returns(presenter)

    get :show, id: specialist_guide.slug, format: 'json'
    assert_equal({'status' => 'ok'}, json_response['_response_info'])
  end

  test "show responds with 404 if published guide not found" do
    SpecialistGuide.stubs(:published_as).returns(nil)
    get :show, id: 'unknown', format: 'json'
    assert_response :not_found
    assert_equal({'status' => 'not found'}, json_response['_response_info'])
  end

  test "index paginates published specialist guides" do
    presenter = Api::SpecialistGuidePresenter::PagePresenter.new([])
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::SpecialistGuidePresenter.stubs(:paginate).with(SpecialistGuide.published.alphabetical).returns(presenter)

    get :index, format: 'json'

    assert_equal 'representation', json_response['paged']
  end

  test "index includes _response_info in response" do
    presenter = Api::SpecialistGuidePresenter::PagePresenter.new([])
    presenter.stubs(:as_json).returns(paged: :representation)
    Api::SpecialistGuidePresenter.stubs(:paginate).with(SpecialistGuide.published.alphabetical).returns(presenter)

    get :index, format: 'json'

    assert_equal({'status' => 'ok'}, json_response['_response_info'])
  end

  private

  def json_response
    ActiveSupport::JSON.decode(response.body)
  end
end
