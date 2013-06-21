require "test_helper"

class TopicalEventsControllerTest < ActionController::TestCase
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

  view_test "#show displays a maximum of 6 featured editions" do
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

    feed_url = ERB::Util.html_escape(topical_event_url(event, format: "atom"))
    assert_select "a.feed[href=?]", feed_url
  end

  view_test 'show has a link to email signup page' do
    event = create(:topical_event)

    get :show, id: event

    assert_select ".govdelivery[href='#{email_signups_path(topic: event.slug)}']"
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
end
