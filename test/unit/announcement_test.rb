require "test_helper"

class AnnouncementTest < ActiveSupport::TestCase
  test "should be able to find an announcement by slug" do
    news = create(:published_news_article)
    speech = create(:published_speech)

    assert_equal news, Announcement.published_as(news.document.slug)
    assert_equal speech, Announcement.published_as(speech.document.slug)
  end
end