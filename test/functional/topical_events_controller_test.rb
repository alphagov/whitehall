require "test_helper"

class TopicalEventsControllerTest < ActionController::TestCase
  include FeedHelper

  should_be_a_public_facing_controller

  test "#index redirects to topics homepage" do
    get :index
    assert_redirected_to :topics
  end

  test "#show displays primary featured editions in ordering defined by association" do
    topical_event = create(:topical_event)
    news_article = create(:published_news_article)
    policy = create(:published_policy)
    create(:classification_featuring, classification: topical_event, edition: news_article, ordering: 0)
    create(:classification_featuring, classification: topical_event, edition: policy, ordering: 1)

    get :show, id: topical_event

    assert_equal [news_article, policy], assigns(:featured_editions).collect(&:model)
  end

  view_test "#show displays a maximum of 5 featured editions" do
    topical_event = create(:topical_event)
    editions = []
    7.times do |i|
      edition = create(:published_news_article)
      editions << create(:classification_featuring, edition: edition, classification: topical_event, ordering: i)
    end

    get :show, id: topical_event

    editions[0...5].each do |edition|
      assert_select_object edition.edition
    end
    refute_select_object editions.last.edition
  end

  view_test 'show has a link to the atom feed' do
    event = create(:topical_event)

    get :show, id: event

    assert_select "a.feed[href=?]", atom_feed_url_for(event)
  end

  view_test 'show has a link to email signup page' do
    event = create(:topical_event)

    get :show, id: event

    assert_select ".govdelivery[href='#{new_email_signups_path(email_signup: { feed: atom_feed_url_for(event) })}']"
  end

  view_test "#show displays extra org logos for first-world-war-centenary" do
    topical_event = create(:topical_event, name: 'First World War Centenary')
    create(:organisation_classification, lead: true, classification: topical_event)

    get :show, id: topical_event

    assert_select '.arts-council-england'
    assert_select '.bbc'
    assert_select '.british-library'
    assert_select '.commonwealth-war-graves-commission'
    assert_select '.english-heritage'
    assert_select '.heritage-lottery-fund'
    assert_select '.imperial-war-museums'
    assert_select '.war-memorials-trust'
  end

  view_test "#show doesn't show extra org logos for non first-world-war-centenary" do
    topical_event = create(:topical_event, name: 'Something exciting')
    create(:organisation_classification, lead: true, classification: topical_event)

    get :show, id: topical_event

    refute_select '.arts-council-england'
    refute_select '.bbc'
    refute_select '.british-library'
    refute_select '.commonwealth-war-graves-commission'
    refute_select '.english-heritage'
    refute_select '.heritage-lottery-fund'
    refute_select '.imperial-war-museums'
    refute_select '.war-memorials-trust'
  end

  test "sets a meta description" do
    topical_event = create(:topical_event, description: 'my description')

    get :show, id: topical_event

    assert_equal 'my description', assigns(:meta_description)
  end

  view_test 'GET :show renders an atom feed' do
    topical_event = create(:topical_event)
    policy = create(:published_policy, topical_events: [topical_event])

    get :show, id: topical_event, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > author, feed > entry > author'
      assert_select 'feed > updated', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml', topical_event_url(topical_event, format: 'atom'), 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', topical_event_url(topical_event), 1

      assert_select_atom_entries([policy])
    end
  end
end
