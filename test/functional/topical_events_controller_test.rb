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

  test "#show displays a maximum of 6 featured editions" do
    topical_event = create(:topical_event)
    editions = []
    7.times do |i|
      edition = create(:published_news_article)
      editions << create(:classification_featuring, edition: edition, classification: topical_event, ordering: i)
    end

    get :show, id: topical_event

    editions[0...6].each do |edition|
      assert_select_object edition.edition
    end
    refute_select_object editions.last.edition
  end

  test 'show has a link to the atom feed' do
    event = create(:topical_event)

    get :show, id: event

    feed_url = ERB::Util.html_escape(topic_url(event, format: "atom"))
    assert_select "a.feed[href=?]", feed_url
  end
  test 'show has a link to govdelivery if one exists' do
    event = create(:topical_event, govdelivery_url: 'http://my-govdelivery-url.com')

    get :show, id: event

    assert_select ".govdelivery[href='http://my-govdelivery-url.com']"
  end
end
