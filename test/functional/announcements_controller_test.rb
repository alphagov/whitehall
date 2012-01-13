require "test_helper"

class AnnouncementsControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper

  should_be_a_public_facing_controller
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

  test "index shows news and speeches from the last 24 hours" do
    older_announcements = [create(:published_news_article, published_at: 25.hours.ago), create(:published_speech, published_at: 26.hours.ago)]
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    get :index

    assert_equal announced_today, assigns[:announced_today]

    assert_select '#last_24_hours' do
      announced_today.each do |announcement|
        assert_select_object announcement
      end
    end
  end

  test "featured stories should not appear in the last 24 hours or last 7 days lists of announcements" do
    featured = [
      create(:published_news_article, featured: true, published_at: Time.zone.now),
      create(:published_news_article, featured: true, published_at: 24.hours.ago),
      create(:published_news_article, featured: true, published_at: 2.days.ago)
    ]

    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    announced_in_last_7_days = [
      create(:published_news_article, published_at: 24.hours.ago),
      create(:published_speech, published_at: 6.days.ago),
    ]

    get :index

    assert_equal featured, assigns[:featured_news_articles]
    assert_equal announced_today, assigns[:announced_today]
    assert_equal announced_in_last_7_days, assigns[:announced_in_last_7_days]
  end

  test "index highlights first three announcements that have been published in the last 24 hours" do
    announced_today = [
      create(:published_news_article, published_at: Time.zone.now),
      create(:published_speech, published_at: 1.hour.ago),
      create(:published_speech, published_at: 2.hours.ago),
      create(:published_news_article, published_at: 3.hours.ago)
    ]

    get :index

    assert_select '#last_24_hours' do
      assert_select 'article', count: 4

      assert_select '.expanded' do
        assert_select 'article', count: 3
        announced_today.take(3).each do |announcement|
          assert_select_object announcement do
            assert_select "a[href='#{announcement_path(announcement)}'] img"
            assert_select_announcement_title announcement
            assert_select_announcement_summary announcement
            assert_select_announcement_metadata announcement
          end
        end
      end

      announced_today.from(4).each do |announcement|
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

  test "index shows news and speeches from the last 7 days excluding those within the last 24 hours" do
    older_announcements = [create(:published_news_article, published_at: 8.days.ago), create(:published_speech, published_at: 8.days.ago)]
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    announced_in_last_7_days = [
      create(:published_news_article, published_at: 24.hours.ago),
      create(:published_speech, published_at: 6.days.ago),
    ]

    get :index

    assert_equal announced_in_last_7_days.to_set, assigns[:announced_in_last_7_days].to_set
  end

  test "should display list of correctly formatted announcements for the last 7 days" do
    announced_today = [create(:published_news_article, published_at: Time.zone.now), create(:published_speech, published_at: (23.hours.ago + 59.minutes))]

    announced_in_last_7_days = [
      create(:published_news_article, published_at: 1.day.ago),
      create(:published_speech, published_at: 2.days.ago),
      create(:published_news_article, published_at: 3.days.ago),
      create(:published_news_article, published_at: 4.days.ago),
      create(:published_news_article, published_at: 5.days.ago),
      create(:published_speech, published_at: 5.days.ago),
      create(:published_speech, published_at: 6.days.ago),
    ]

    get :index

    assert_select '#last_7_days' do
      assert_select 'article', count: 7
      assert_select '.expanded', count: 0

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

  test "most recent news articles should show article image or placeholder if it isn't present" do
    news_with_image = create(:published_news_article, published_at: 2.hours.ago, image: fixture_file_upload('portas-review.jpg'))
    news_without_image = create(:published_news_article, published_at: 3.hours.ago)

    get :index

    assert_select '#last_24_hours .expanded' do
      assert_select_object news_with_image do
        assert_select ".img img[src='#{news_with_image.image_url}']"
      end
      assert_select_object news_without_image do
        assert_select ".img img[src*='evil_placeholder.png']"
      end
    end
  end

  test "announcements in the last 7 days should show expanded view if there are no stories in the last 24 hours" do
    announced_in_last_7_days = [
      create(:published_news_article, published_at: 1.day.ago),
      create(:published_speech, published_at: 2.days.ago),
      create(:published_news_article, published_at: 3.days.ago),
      create(:published_news_article, published_at: 4.days.ago)
    ]

    get :index

    refute_select '#last_24_hours'

    assert_select '#last_7_days' do
      assert_select 'article', count: 4
      assert_select '.expanded' do
        assert_select 'article', count: 3
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
      time_string = speech.published_at.to_s(:long_ordinal)
      assert_select "abbr.published_at[title='#{speech.published_at.iso8601}']", text: /#{time_string}/i
      appointment = speech.role_appointment
      assert_select "a.ministerial_role[href='#{ministerial_role_path(appointment.role)}']", text: appointment.person.name
    end
  end

  def assert_select_news_article_metadata(news_article)
    time_string = news_article.published_at.to_s(:long_ordinal)
    assert_select ".meta abbr.published_at[title='#{news_article.published_at.iso8601}']", text: /#{time_string}/i
  end
end