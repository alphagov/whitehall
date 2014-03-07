require "test_helper"

class LatestControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'GET :index should handle organisations' do
    organisation = create(:organisation)

    get :index, departments: [organisation]

    assert_equal organisation, @controller.subject
  end

  test 'GET :index should handle topics' do
    topic = create(:topic)

    get :index, topics: [topic]

    assert_equal topic, @controller.subject
  end

  test 'GET :index should handle topical events' do
    topical_event = create(:topical_event)

    get :index, topics: [topical_event]

    assert_equal topical_event, @controller.subject
  end

  test 'GET :index should handle world locations' do
    world_location = create(:world_location)

    get :index, world_locations: [world_location]

    assert_equal world_location, @controller.subject
  end

  test 'GET :index should expose documents for the subject' do
    organisation = create(:organisation)

    policy_paper = create(:published_policy_paper,
                          organisations: [organisation],
                          first_published_at: 1.day.ago)
    detailed_guide = create(:published_detailed_guide,
                            organisations: [organisation],
                            first_published_at: 2.days.ago)

    get :index, departments: [organisation]

    assert_equal [policy_paper, detailed_guide], @controller.documents
  end

  test 'GET :index should accept pagination parameters' do
    organisation = create(:organisation)

    policy_paper = create(:published_policy_paper,
                          organisations: [organisation],
                          first_published_at: 1.day.ago)
    detailed_guide = create(:published_detailed_guide,
                            organisations: [organisation],
                            first_published_at: 2.days.ago)

    get :index, departments: [organisation], page: 2

    assert_equal [], @controller.documents
  end
end
