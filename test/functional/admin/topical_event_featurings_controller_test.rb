require "test_helper"

class Admin::TopicalEventFeaturingsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @topical_event = create(:topical_event)
    login_as :writer
  end

  test "GET :index assigns tagged_editions with a paginated collection of published editions related to the topical_event ordered by most recently created editions first" do
    news_article1 = create(:published_news_article, topical_events: [@topical_event])
    news_article2 = Timecop.travel(10.minutes) { create(:published_news_article, topical_events: [@topical_event]) }
    _draft_article = create(:news_article, topical_events: [@topical_event])
    _unrelated_article = create(:news_article, :with_topical_events)

    get :index, params: { topical_event_id: @topical_event, page: 1 }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article2, news_article1], tagged_editions
    assert_equal 1, tagged_editions.current_page
    assert_equal 1, tagged_editions.total_pages
    assert_equal 25, tagged_editions.limit_value
  end

  test "GET :index assigns a filtered list to tagged_editions when given a title" do
    create(:published_news_article, topical_events: [@topical_event])
    news_article = create(:published_news_article, topical_events: [@topical_event], title: "Specific title")
    _unrelated_article = create(:published_news_article, :with_topical_events, title: "Specific title")

    get :index, params: { topical_event_id: @topical_event, title: "specific" }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given an organisation" do
    create(:published_news_article, topical_events: [@topical_event])
    org = create(:organisation)
    news_article = create(:published_news_article, topical_events: [@topical_event])
    news_article.organisations << org

    get :index, params: { topical_event_id: @topical_event, organisation: org.id }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given an author" do
    create(:published_news_article, topical_events: [@topical_event])
    news_article = create(:published_news_article, topical_events: [@topical_event])
    user = create(:user)
    create(:edition_author, edition: news_article, user: user)

    get :index, params: { topical_event_id: @topical_event, author: user.id }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given a document type" do
    news_article = create(:published_news_article, topical_events: [@topical_event])

    get :index, params: { topical_event_id: @topical_event, type: news_article.display_type_key }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article], tagged_editions
  end

  view_test "GET :index contains a message when no results matching search criteria were found" do
    create(:published_news_article, topical_events: [@topical_event])

    get :index, params: { topical_event_id: create(:topical_event) }

    assert_equal 0, assigns(:tagged_editions).count
    assert_match "No documents found", response.body
  end

  test "PUT :order saves the new order of featurings" do
    feature1 = create(:topical_event_featuring, topical_event: @topical_event)
    feature2 = create(:topical_event_featuring, topical_event: @topical_event)
    feature3 = create(:topical_event_featuring, topical_event: @topical_event)

    Whitehall::PublishingApi.expects(:republish_async).with(@topical_event).once

    put :order,
        params: { topical_event_id: @topical_event,
                  ordering: {
                    feature1.id.to_s => "1",
                    feature2.id.to_s => "2",
                    feature3.id.to_s => "0",
                  } }

    assert_response :redirect
    assert_equal [feature3, feature1, feature2], @topical_event.reload.topical_event_featurings
  end

  view_test "GET :new renders only image fields if featuring an edition" do
    edition = create :edition
    get :new, params: { topical_event_id: @topical_event.id, edition_id: edition.id }

    assert_select "#topical_event_featuring_image_attributes_file"
    assert_select "#topical_event_featuring_alt_text"
  end

  view_test "GET :new renders all fields if not featuring an edition" do
    offsite_link = create :offsite_link
    get :new, params: { topical_event_id: @topical_event.id, offsite_link_id: offsite_link.id }

    assert_select "#topical_event_featuring_image_attributes_file"
    assert_select "#topical_event_featuring_alt_text"
  end

  test "DELETE :destroy unfeatures edition and redirects to topical_event" do
    featuring = create(:topical_event_featuring,
                       topical_event: create(:topical_event))

    assert_difference("TopicalEventFeaturing.count", -1) do
      delete :destroy, params: {
        topical_event_id: featuring.topical_event.id, id: featuring.id
      }
    end

    assert_response :redirect
  end

  test "DELETE :destroy unfeatures offsite link and redirects to topical_event" do
    offsite_featuring = create(:offsite_topical_event_featuring,
                               topical_event: create(:topical_event))

    assert_difference("TopicalEventFeaturing.count", -1) do
      delete :destroy, params: {
        topical_event_id: offsite_featuring.topical_event.id, id: offsite_featuring.id
      }
    end

    assert_response :redirect
  end
end
