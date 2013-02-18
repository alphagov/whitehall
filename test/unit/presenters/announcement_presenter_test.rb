require "test_helper"

class AnnouncementPresenterTest < PresenterTestCase
  test "shows correct human readable format for speeches" do
    speech_types = {
      SpeechType::Transcript => "Speech",
      SpeechType::DraftText => "Speech",
      SpeechType::SpeakingNotes => "Speech",
      SpeechType::WrittenStatement => "Statement to parliament",
      SpeechType::OralStatement => "Statement to parliament"
    }

    speech_types.each do |type, expected|
      speech = AnnouncementPresenter.decorate(Speech.new(speech_type: type))
      assert_equal expected, speech.display_type
    end
  end

  test 'shows correct human readable format for news articles' do
    news_article_types = {
      NewsArticleType::NewsStory => "News story",
      NewsArticleType::PressRelease => "Press release",
      NewsArticleType::Rebuttal => "Rebuttal"
    }

    news_article_types.each do |type, expected|
      news_article = AnnouncementPresenter.decorate(NewsArticle.new(news_article_type: type))
      assert_equal expected, news_article.display_type
    end
  end
end
