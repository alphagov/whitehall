require "test_helper"
require "gds_api/test_helpers/rummager"
require_relative "../support/search_rummager_helper"

class LatestControllerTest < ActionController::TestCase
  include SearchRummagerHelper

  should_be_a_public_facing_controller

  test 'GET :index should handle organisations' do
    organisation = create(:organisation)

    get :index, params: { departments: [organisation] }

    assert_equal organisation, @controller.send(:subject)
  end

  test 'GET :index should handle topical events' do
    topical_event = create(:topical_event)

    get :index, params: { topical_events: [topical_event] }

    assert_equal topical_event, @controller.send(:subject)
  end

  test 'GET :index should handle world locations' do
    world_location = create(:world_location)

    get :index, params: { world_locations: [world_location] }

    assert_equal world_location, @controller.send(:subject)
  end

  test 'GET :index should redirect to feed if subject is not provided' do
    get :index

    assert_response :redirect
    assert_redirected_to "/government/feed"
  end

  test 'GET :index should expose rummager documents for the subject' do
    topical_event = create(:topical_event)

    stub_any_rummager_search.to_return(body: rummager_response)

    get :index, params: { topical_events: [topical_event] }

    assert_equal attributes(processed_rummager_documents),
                 attributes(@controller.send(:documents))
  end

  test 'GET :index should accept pagination parameters with rummager documents' do
    world_location = create(:world_location)

    stub_any_rummager_search.to_return(body: rummager_response)

    get :index, params: { world_locations: [world_location], page: 2 }

    assert_equal [], @controller.send(:documents)
  end

  test 'GET :index should expose documents for the subject' do
    organisation = create(:organisation)

    stub_any_rummager_search.to_return(body: rummager_response)

    get :index, params: { departments: [organisation] }

    assert_equal attributes(processed_rummager_documents),
                 attributes(@controller.send(:documents))
  end

  test 'GET :index should accept pagination parameters' do
    organisation = create(:organisation)

    stub_any_rummager_search.to_return(body: rummager_response)

    get :index, params: { departments: [organisation], page: 2 }

    assert_equal [], @controller.send(:documents)
  end
end
