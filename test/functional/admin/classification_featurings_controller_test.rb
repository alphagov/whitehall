require 'test_helper'

class Admin::ClassificationFeaturingsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @topic = create(:topic)
    login_as :policy_writer
  end

  test "GET :index assigns tagged_editions with a paginated collection of published editions related to the topic ordered by most recently created editions first" do
    @news_article_foo = create(:published_news_article, :with_topics, topics: [@topic])
    Timecop.travel(10.minutes) do
      @news_article_bar = create(:published_news_article, :with_topics, topics: [@topic])
    end
    draft_article = create(:news_article, :with_topics, topics: [@topic])
    unrelated_article = create(:news_article, :with_topics)

    get :index, topic_id: @topic, page: 1

    tagged_editions = assigns(:tagged_editions)
    assert_equal [@news_article_bar, @news_article_foo], tagged_editions
    assert_equal 1, tagged_editions.current_page
    assert_equal 1, tagged_editions.num_pages
    assert_equal 25, tagged_editions.limit_value
  end

  test "GET :index assigns a filtered list to tagged_editions when given a title" do
    create(:published_news_article, :with_topics, topics: [@topic])
    @news_article_foo = create(:published_news_article, :with_topics, topics: [@topic], title: 'foo in the title')

    get :index, topic_id: @topic, title: 'foo'

    tagged_editions = assigns(:tagged_editions)
    assert_equal [@news_article_foo], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given an organisation" do
    create(:published_news_article, :with_topics, topics: [@topic])
    org = create(:organisation)
    @news_article_foo = create(:published_news_article, :with_topics, topics: [@topic])
    @news_article_foo.organisations << org

    get :index, topic_id: @topic, organisation: org.id

    tagged_editions = assigns(:tagged_editions)
    assert_equal [@news_article_foo], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given an author" do
    create(:published_news_article, :with_topics, topics: [@topic])
    @news_article_foo = create(:published_news_article, :with_topics, topics: [@topic])
    user = create(:user)
    create(:edition_author, edition: @news_article_foo, user: user)

    get :index, topic_id: @topic, author: user.id

    tagged_editions = assigns(:tagged_editions)
    assert_equal [@news_article_foo], tagged_editions
  end

  test "GET :index assigns a filtered list to tagged_editions when given a document type" do
    create(:published_statistical_data_set, :with_topics, topics: [@topic])
    @news_article_foo = create(:published_news_article, :with_topics, topics: [@topic])

    get :index, topic_id: @topic, type: @news_article_foo.display_type_key

    tagged_editions = assigns(:tagged_editions)
    assert_equal [@news_article_foo], tagged_editions
  end

  test "PUT :order saves the new order of featurings" do
    feature1 = create(:classification_featuring, classification: @topic)
    feature2 = create(:classification_featuring, classification: @topic)
    feature3 = create(:classification_featuring, classification: @topic)

    put :order, topic_id: @topic, ordering: {
                                        feature1.id.to_s => '1',
                                        feature2.id.to_s => '2',
                                        feature3.id.to_s => '0'
                                      }

    assert_response :redirect
    assert_equal [feature3, feature1, feature2], @topic.reload.classification_featurings
  end
end
