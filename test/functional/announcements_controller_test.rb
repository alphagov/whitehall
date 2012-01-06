require "test_helper"

class AnnouncementsControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper

  should_show_featured_documents_for :news_article

  test "index highlights three featured news articles" do
    articles = 3.times.map do |n|
      create(:published_news_article, featured: true, published_at: n.days.ago)
    end

    get :index

    assert_equal articles.take(3), assigns[:featured_news_articles]
    assert_select '.featured_items' do
      articles.take(3).each do |article|
        assert_select_object article
      end
    end
  end

  test "index shows other news articles and speeches" do
    3.times.map do |n|
      create(:published_news_article, featured: true, published_at: n.days.ago)
    end

    announcements = 5.times.map do |n|
      [create(:published_news_article, published_at: (n * 2).days.ago), create(:published_speech, published_at: (n * 2 + 1).days.ago)]
    end.flatten

    get :index

    assert_equal announcements, assigns[:announcements]
  end

  test "index shows full details for 6 most recent announcements" do
    announcements = 10.times.map do |n|
      [create(:published_news_article, published_at: (n * 2).days.ago), create(:published_speech, published_at: (n * 2 + 1).days.ago)]
    end.flatten

    get :index

    assert_select '.most_recent' do
      announcements.take(6).each do |announcement|
        assert_select_object announcement do
          assert_select "a[href='#{announcement_path(announcement)}'] img"
          assert_select_announcement_title announcement
          assert_select_announcement_summary announcement
          assert_select_announcement_metadata announcement
        end
      end
    end
  end

  test "index shows partial details for next 12 most recent announcements" do
    announcements = 10.times.map do |n|
      [create(:published_news_article, published_at: (n * 2).days.ago), create(:published_speech, published_at: (n * 2 + 1).days.ago)]
    end.flatten

    get :index

    assert_select '.less_recent' do
      announcements.from(6).take(12).each do |announcement|
        assert_select_object announcement do
          assert_select_announcement_title announcement
          assert_select_announcement_summary announcement
          assert_select_announcement_metadata announcement
        end
      end
    end
  end

  test "index shows unique related policy areas for each news article" do
    first_policy_area = create(:policy_area, name: 'first-area')
    second_policy_area = create(:policy_area, name: 'second-area')
    policy_1 = create(:published_policy, policy_areas: [first_policy_area, second_policy_area])
    policy_2 = create(:published_policy, policy_areas: [first_policy_area])
    news_article = create(:published_news_article, published_at: 4.days.ago, related_policies: [policy_1, policy_2])

    get :index

    assert_select_object news_article do
      assert_select ".meta a[href='#{policy_area_path(first_policy_area)}']", text: first_policy_area.name, count: 1
      assert_select ".meta a[href='#{policy_area_path(second_policy_area)}']", text: second_policy_area.name, count: 1
    end
  end

  test "should avoid n+1 queries when displaying speeches" do
    speeches = []
    ordered_published_speeches = mock("ordered_published_speeches")
    ordered_published_speeches.expects(:includes).with(:document_identity, role_appointment: [:person, :role]).returns(speeches)
    published_speeches = mock("published_speeches")
    published_speeches.expects(:by_published_at).returns(ordered_published_speeches)
    Speech.expects(:published).returns(published_speeches)

    get :index
  end

  test "should avoid n+1 queries when displaying news articles" do
    news_articles = []
    ordered_published_news_articles = mock("ordered_published_news_articles")
    ordered_published_news_articles.expects(:includes).with(:document_identity, :document_relations, :policy_areas).returns(news_articles)
    ordered_news_articles = mock("ordered_news_articles")
    ordered_news_articles.expects(:by_published_at).returns(ordered_published_news_articles)
    NewsArticle.expects(:published).returns(ordered_news_articles)

    get :index
  end

  private

  def announcement_path(announcement)
    if announcement.is_a?(NewsArticle)
      news_article_path(announcement.document_identity)
    else
      speech_path(announcement.document_identity)
    end
  end

  def assert_select_announcement_title(announcement)
    assert_select "h2 a[href='#{announcement_path(announcement)}']", text: announcement.title
  end

  def assert_select_announcement_summary(announcement)
    assert_select "p.summary", text: announcement.summary
  end

  def assert_select_announcement_metadata(announcement)
    if announcement.is_a?(Speech)
      assert_select_speech_metadata(announcement)
    else
      assert_select_news_article_metadata(announcement)
    end
  end

  def assert_select_speech_metadata(speech)
    assert_select ".meta" do
      time_ago = time_ago_in_words(speech.published_at)
      assert_select ".published_at", text: /delivered (?:[\s]*) #{time_ago} ago/i
      appointment = speech.role_appointment
      assert_select "a.ministerial_role[href='#{ministerial_role_path(appointment.role)}']", text: appointment.person.name
    end
  end

  def assert_select_news_article_metadata(news_article)
    time_ago = time_ago_in_words(news_article.published_at)
    assert_select ".meta .published_at", text: /posted (?:[\s]*) #{time_ago} ago/i
  end
end