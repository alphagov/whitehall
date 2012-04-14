require "test_helper"

class AnnouncementsControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper

  should_be_a_public_facing_controller

  test "index shows news and speeches from the last 24 hours" do
    announced_today = [create(:published_news_article), create(:published_speech)]
    AnnouncementPresenter.any_instance.stubs(:today).returns(AnnouncementPresenter::Set.new(announced_today))

    get :index

    assert_select '#last_24_hours' do
      announced_today.each do |announcement|
        assert_select_object announcement
      end
    end
  end

  test "index highlights first three announcements with images that have been published in the last 24 hours" do
    featured = [create(:published_news_article), create(:published_speech), create(:published_news_article)]
    unfeatured = [create(:published_news_article), create(:published_speech), create(:published_news_article),
                  create(:published_news_article)]

    today = stub("today", featured: featured, unfeatured: unfeatured, any?: true)
    AnnouncementPresenter.any_instance.stubs(:today).returns(today)

    get :index

    assert_select '#last_24_hours' do
      assert_select 'article', count: 7


        assert_select 'article', count: 7
        featured.each do |announcement|
          assert_select_object announcement do
            assert_select "a[href='#{announcement_path(announcement)}'] img"
            assert_select_announcement_title announcement
            assert_select_announcement_summary announcement
            assert_select_announcement_metadata announcement
          end
        end
  

      unfeatured.each do |announcement|
        assert_select_object announcement do
          refute_select "img"
          assert_select_announcement_title announcement
          assert_select_announcement_summary announcement
          assert_select_announcement_metadata announcement
        end
      end
    end
  end

  test "should not display #last_24_hours section if there aren't any announcements within that period" do
    get :index
    refute_select '#last_24_hours'
  end

  test "should display list of correctly formatted announcements for the last 7 days" do
    announced_in_last_7_days = [
      create(:published_news_article),
      create(:published_speech),
      create(:published_news_article)
    ]
    AnnouncementPresenter.any_instance.stubs(:in_last_7_days).returns(AnnouncementPresenter::Set.new(announced_in_last_7_days))

    get :index

    assert_select '#last_7_days' do
      assert_select 'article', count: 3

      announced_in_last_7_days.each do |announcement|
        assert_select_object announcement do
          refute_select "img"
          assert_select_announcement_title announcement
          assert_select_announcement_summary announcement
          assert_select_announcement_metadata announcement
        end
      end
    end
  end

  test "should not show images for any announcements in last 7 days if some exist in the last 24 hours" do
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    announced_in_last_7_days = [
      create(:published_news_article),
      create(:published_speech),
      create(:published_news_article)
    ]
    AnnouncementPresenter.any_instance.stubs(:today).returns(AnnouncementPresenter::Set.new(announced_today))
    AnnouncementPresenter.any_instance.stubs(:in_last_7_days).returns(AnnouncementPresenter::Set.new(announced_in_last_7_days))

    get :index

    assert_select '#last_7_days' do

      announced_in_last_7_days.each do |announcement|
        assert_select_object announcement do
          refute_select "img"
        end
      end
    end
  end

  test "announcements in the last 7 days should show expanded view if there are no stories in the last 24 hours" do
    unfeatured = [create(:published_news_article), create(:published_speech)]
    featured = [create(:published_news_article)]

    announced_in_last_7_days = stub("last_7_days", featured: featured, unfeatured: unfeatured, any?: true)

    AnnouncementPresenter.any_instance.stubs(:today).returns(AnnouncementPresenter::Set.new([]))
    AnnouncementPresenter.any_instance.stubs(:in_last_7_days).returns(announced_in_last_7_days)

    get :index

    refute_select '#last_24_hours'

    assert_select '#last_7_days' do
      assert_select 'article', count: 3
    end
  end

  test "index shows unique related policy topics for each news article" do
    first_policy_topic = create(:policy_topic, name: 'first-area')
    second_policy_topic = create(:policy_topic, name: 'second-area')
    policy_1 = create(:published_policy, policy_topics: [first_policy_topic, second_policy_topic])
    policy_2 = create(:published_policy, policy_topics: [first_policy_topic])
    news_article = create(:published_news_article, published_at: 4.days.ago, related_policies: [policy_1, policy_2])

    get :index

    assert_select_object news_article do
      assert_select ".meta a[href='#{policy_topic_path(first_policy_topic)}']", text: first_policy_topic.name, count: 1
      assert_select ".meta a[href='#{policy_topic_path(second_policy_topic)}']", text: second_policy_topic.name, count: 1
    end
  end

  test "index shows featured news articles" do
    a = create(:featured_news_article, published_at: 1.day.ago)
    b = create(:featured_news_article, published_at: 2.days.ago)
    c = create(:featured_news_article, published_at: 3.days.ago)
    d = create(:featured_news_article, published_at: 4.days.ago)

    get :index

    assert_select '#featured_news' do
      assert_select_object a
      assert_select_object b
      assert_select_object c
      refute_select_object d
    end
  end

  test "featured news article should show images, title, summary and meta details" do
    first_policy_topic = create(:policy_topic, name: 'first-area')
    second_policy_topic = create(:policy_topic, name: 'second-area')
    policy_1 = create(:published_policy, policy_topics: [first_policy_topic, second_policy_topic])
    policy_2 = create(:published_policy, policy_topics: [first_policy_topic])
    featured_news = create(:featured_news_article, published_at: 1.day.ago, related_policies: [policy_1, policy_2])
    get :index

    assert_select '#featured_news' do
      assert_select_object featured_news do
        assert_select "a[href='#{announcement_path(featured_news)}'] img"
        assert_select_announcement_title featured_news
        assert_select_announcement_summary featured_news
        assert_select_announcement_metadata featured_news
        assert_select ".meta a[href='#{policy_topic_path(first_policy_topic)}']", text: first_policy_topic.name, count: 1
        assert_select ".meta a[href='#{policy_topic_path(second_policy_topic)}']", text: second_policy_topic.name, count: 1
      end
    end
  end

  private

  def announcement_path(announcement)
    if announcement.is_a?(NewsArticle)
      news_article_path(announcement.doc_identity)
    else
      speech_path(announcement.doc_identity)
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
      time_string = speech.delivered_on.to_s(:long_ordinal)
      assert_select "abbr.delivered_on[title='#{speech.delivered_on.iso8601}']", text: /#{time_string}/i
      appointment = speech.role_appointment
      assert_select "a.ministerial_role[href='#{ministerial_role_path(appointment.role)}']", text: appointment.person.name
    end
  end

  def assert_select_news_article_metadata(news_article)
    time_string = news_article.first_published_at.to_s(:long_ordinal)
    assert_select ".meta abbr.first_published_at[title='#{news_article.first_published_at.iso8601}']", text: /#{time_string}/i
  end
end
