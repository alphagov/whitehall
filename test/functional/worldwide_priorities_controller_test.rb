# encoding: utf-8
require "test_helper"

class WorldwidePrioritiesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_render_a_list_of :worldwide_priorities
  should_show_the_world_locations_associated_with :worldwide_priority
  should_display_inline_images_for :worldwide_priority
  should_set_meta_description_for :worldwide_priority
  should_set_slimmer_analytics_headers_for :worldwide_priority

  view_test "show displays worldwide priority details" do
    priority = create(:published_worldwide_priority,
      title: "priority-title",
      body: "priority-body",
    )

    get :show, id: priority.document

    assert_select "h1", "priority-title"
    assert_select ".body", "priority-body"
    refute_select "nav.activity-navigation"
  end

  view_test '#show includes navigation tabs when there are related published prioritys' do
    priority = create(:published_worldwide_priority)
    news     = create(:published_world_location_news_article, related_editions: [priority])

    get :show, id: priority.document

    assert_response :success
    assert_template :show
    assert_equal priority, assigns(:document)
    assert_select "nav.activity-navigation"
  end

  view_test "should display the associated organisations" do
    first_organisation  = create(:organisation)
    second_organisation = create(:organisation)
    third_organisation  = create(:organisation)
    priority            = create(:published_worldwide_priority, organisations: [first_organisation, second_organisation])

    get :show, id: priority.document

    assert_select_object first_organisation
    assert_select_object second_organisation
    refute_select_object third_organisation
  end

  view_test "should not display an empty list of organisations" do
    priority = create(:published_worldwide_priority, organisations: [])

    get :show, id: priority.document

    refute_select "#organisations"
  end

  view_test "should display translated page labels when requested in a different locale" do
    priority = create(:published_worldwide_priority, translated_into: 'fr')

    get :show, id: priority.document, locale: 'fr'

    assert_select ".type", /Priorité internationale/
    assert_select ".change-notes-title", /Historique de page/
  end

  test '#activity loads the recently changed documents related to the priority' do
    priority = create(:published_worldwide_priority)
    news     = create(:published_world_location_news_article, related_editions: [priority])
    speech   = create(:published_speech, related_editions: [priority])
    draft    = create(:draft_world_location_news_article, related_editions: [priority])

    get :activity, id: priority.document

    assert_response :success
    assert_template :activity
    assert_equal priority, assigns(:document)
    assert_equal [speech, news], assigns(:related_editions)
  end
end
