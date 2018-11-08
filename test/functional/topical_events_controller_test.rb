require "test_helper"
require 'gds_api/test_helpers/content_store'
require_relative '../support/search_rummager_helper'

class TopicalEventsControllerTest < ActionController::TestCase
  include FeedHelper
  include GdsApi::TestHelpers::ContentStore
  include SearchRummagerHelper

  should_be_a_public_facing_controller

  test "#show displays primary featured editions in ordering defined by association" do
    topical_event = create_topical_event_and_stub_in_content_store
    news_article = create(:published_news_article)
    publication = create(:published_publication)
    news_article_featuring = create(:classification_featuring, classification: topical_event, edition: news_article, ordering: 0)
    publication_featuring = create(:classification_featuring, classification: topical_event, edition: publication, ordering: 1)

    get :show, params: { id: topical_event }

    assert_equal [news_article_featuring, publication_featuring], assigns(:featurings)
  end

  view_test "#show displays a maximum of 5 featured editions" do
    topical_event = create_topical_event_and_stub_in_content_store
    editions = []
    7.times do |i|
      edition = create(:published_news_article)
      editions << create(:classification_featuring, edition: edition, classification: topical_event, ordering: i)
    end

    get :show, params: { id: topical_event }
    parsed_response = Nokogiri::HTML::Document.parse(response.body)
    assert_equal 5, parsed_response.css('.featured-news .feature').length
  end

  view_test 'show has a link to the atom feed' do
    event = create_topical_event_and_stub_in_content_store

    get :show, params: { id: event }

    assert_select "a.feed[href=?]", atom_feed_url_for(event)
  end

  view_test 'show has a link to email signup page' do
    event = create_topical_event_and_stub_in_content_store

    get :show, params: { id: event }

    assert_select ".govdelivery[href='#{new_email_signups_path(email_signup: { feed: atom_feed_url_for(event) })}']"
  end

  view_test "#show displays extra org logos for first-world-war-centenary" do
    topical_event = create_topical_event_and_stub_in_content_store(name: 'First World War Centenary')
    create(:organisation_classification, lead: true, classification: topical_event)

    get :show, params: { id: topical_event }

    assert_select '.arts-council-england'
    assert_select '.bbc'
    assert_select '.british-library'
    assert_select '.commonwealth-war-graves-commission'
    assert_select '.heritage-lottery-fund'
    assert_select '.historic-england'
    assert_select '.imperial-war-museums'
    assert_select '.war-memorials-trust'
  end

  view_test "#show doesn't show extra org logos for non first-world-war-centenary" do
    topical_event = create_topical_event_and_stub_in_content_store(name: 'Something exciting')
    create(:organisation_classification, lead: true, classification: topical_event)

    get :show, params: { id: topical_event }

    refute_select '.arts-council-england'
    refute_select '.bbc'
    refute_select '.british-library'
    refute_select '.commonwealth-war-graves-commission'
    refute_select '.heritage-lottery-fund'
    refute_select '.historic-england'
    refute_select '.imperial-war-museums'
    refute_select '.war-memorials-trust'
  end

  test "sets a meta description" do
    topical_event = create_topical_event_and_stub_in_content_store(description: 'my description')

    get :show, params: { id: topical_event }

    assert_equal 'my description', assigns(:meta_description)
  end

  view_test 'GET :show renders an atom feed' do
    topical_event = create_topical_event_and_stub_in_content_store
    create(:published_publication, topical_events: [topical_event])

    get :show, params: { id: topical_event }, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml', topical_event_url(topical_event, format: 'atom'), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', topical_event_url(topical_event), 1

      assert_select_atom_entries(processed_rummager_documents, false)
    end
  end

  def create_topical_event_and_stub_in_content_store(*args)
    topical_event = create(:topical_event, *args)
    stub_any_rummager_search.to_return(body: rummager_response)

    payload = {
      format: "topical_event",
      title: "Title of topical event",
    }
    content_store_has_item(topical_event.base_path, payload)

    topical_event
  end
end
