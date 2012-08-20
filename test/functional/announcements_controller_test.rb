require "test_helper"

class AnnouncementsControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper

  should_be_a_public_facing_controller

  test "index shows a mix of news and speeches" do
    announced_today = [create(:published_news_article), create(:published_speech)]

    get :index

    assert_select_object announced_today[0]
    assert_select_object announced_today[1]
  end

  test "index shows which type a record is" do
    announced_today = [create(:published_news_article), create(:published_speech)]

    get :index

    assert_select_object announced_today[0] do
      assert_select ".type", text: "News article"
    end
    assert_select_object announced_today[1] do
      assert_select ".type", text: "Speech"
    end
  end

  test "index shows related organisations for each type of article" do
    first_org = create(:organisation, name: 'first-org', acronym: "FO")
    second_org = create(:organisation, name: 'second-org', acronym: "SO")
    news_article = create(:published_news_article, published_at: 4.days.ago, organisations: [first_org, second_org])
    speech = create(:published_speech, published_at: 5.days.ago, organisations: [second_org])

    get :index

    assert_select_object news_article do
      assert_select ".meta a[href='#{organisation_path(first_org)}']", text: first_org.acronym, count: 1
      assert_select ".meta a[href='#{organisation_path(second_org)}']", text: second_org.acronym, count: 1
    end

    assert_select_object speech do
      assert_select ".meta a[href='#{organisation_path(second_org)}']", text: second_org.acronym, count: 1
    end
  end

  test "index shows articles in reverse chronological order" do
    speech = create(:published_speech, published_at: 5.days.ago)
    news_article = create(:published_news_article, published_at: 4.days.ago)

    get :index

    assert_select "#{record_css_selector(news_article)} + #{record_css_selector(speech)}"
  end

  def assert_documents_appear_in_order_within(containing_selector, expected_documents)
    articles = css_select "#{containing_selector} article"
    expected_document_ids = expected_documents.map { |doc| dom_id(doc) }
    actual_document_ids = articles.map { |a| a["id"] }
    assert_equal expected_document_ids, actual_document_ids
  end

  test "index shows only the first 20 news articles or speeches" do
    news = (0...15).map { |n| create(:published_news_article, published_at: n.days.ago) }
    speeches = (15...25).map { |n| create(:published_speech, published_at: n.days.ago) }

    get :index

    assert_documents_appear_in_order_within("section.announcements", news + speeches[0...5])
    speeches[5..10].each do |speech|
      refute_select_object(speech)
    end
  end

  test "index shows the requested page" do
    news = (0...15).map { |n| create(:published_news_article, published_at: n.days.ago) }
    speeches = (15...25).map { |n| create(:published_speech, published_at: n.days.ago) }

    get :index, page: 2

    assert_documents_appear_in_order_within("section.announcements", speeches[5..10])
    (news + speeches[0...5]).each do |speech|
      refute_select_object(speech)
    end    
  end
end
