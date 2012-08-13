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
    news_article = create(:published_news_article, published_at: 4.days.ago)
    speech = create(:published_speech, published_at: 5.days.ago)

    get :index

    assert_select "#{record_css_selector(news_article)} + #{record_css_selector(speech)}"
  end

end
