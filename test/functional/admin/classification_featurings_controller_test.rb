require 'test_helper'

class Admin::ClassificationFeaturingsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @topic = create(:topic)
    login_as :writer
  end

  test "GET :index assigns tagged_editions with a paginated collection of published editions related to the topic ordered by most recently created editions first" do
    news_article_1    = create(:published_news_article, topics: [@topic])
    news_article_2    = Timecop.travel(10.minutes) { create(:published_news_article, topics: [@topic]) }
    draft_article     = create(:news_article, topics: [@topic])
    unrelated_article = create(:news_article, :with_topics)

    get :index, params: { topic_id: @topic, page: 1 }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article_2, news_article_1], tagged_editions
    assert_equal 1, tagged_editions.current_page
    assert_equal 1, tagged_editions.total_pages
    assert_equal 25, tagged_editions.limit_value
  end

  test "GET :index assigns a filtered list to tagged_editions when given a title" do
    create(:published_news_article, topics: [@topic])
    news_article      = create(:published_news_article, topics: [@topic], title: 'Specific title')
    unrelated_article = create(:published_news_article, :with_topics, title: 'Specific title')

    get :index, params: { topic_id: @topic, title: 'specific' }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given an organisation" do
    create(:published_news_article, topics: [@topic])
    org = create(:organisation)
    news_article = create(:published_news_article, topics: [@topic])
    news_article.organisations << org

    get :index, params: { topic_id: @topic, organisation: org.id }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given an author" do
    create(:published_news_article, topics: [@topic])
    news_article = create(:published_news_article, topics: [@topic])
    user = create(:user)
    create(:edition_author, edition: news_article, user: user)

    get :index, params: { topic_id: @topic, author: user.id }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given a document type" do
    create(:published_statistical_data_set, topics: [@topic])
    news_article = create(:published_news_article, topics: [@topic])

    get :index, params: { topic_id: @topic, type: news_article.display_type_key }

    tagged_editions = assigns(:tagged_editions)
    assert_equal [news_article], tagged_editions
  end

  view_test "GET :index contains a message when no results matching search criteria were found" do
    create(:published_news_article, topics: [@topic])
    news_article = create(:published_news_article, topics: [@topic])

    get :index, params: { topic_id: create(:topic) }

    assert_equal 0, assigns(:tagged_editions).count
    assert_match 'No documents found', response.body
  end

  test "PUT :order saves the new order of featurings" do
    feature_1 = create(:classification_featuring, classification: @topic)
    feature_2 = create(:classification_featuring, classification: @topic)
    feature_3 = create(:classification_featuring, classification: @topic)

    put :order, params: { topic_id: @topic, ordering: {
                                        feature_1.id.to_s => '1',
                                        feature_2.id.to_s => '2',
                                        feature_3.id.to_s => '0'
                                      } }

    assert_response :redirect
    assert_equal [feature_3, feature_1, feature_2], @topic.reload.classification_featurings
  end

  view_test "GET :new renders only image fields if featuring an edition" do
    edition = create :edition
    get :new, params: { topic_id: @topic.id, edition_id: edition.id }

    assert_select "#classification_featuring_image_attributes_file"
    assert_select "#classification_featuring_alt_text"
  end

  view_test "GET :new renders all fields if not featuring an edition" do
    offsite_link = create :offsite_link
    get :new, params: { topic_id: @topic.id, offsite_link_id: offsite_link.id }

    assert_select "#classification_featuring_image_attributes_file"
    assert_select "#classification_featuring_alt_text"
  end
end
