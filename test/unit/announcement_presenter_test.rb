require "test_helper"

class AnnouncementPresenterTest < ActiveSupport::TestCase
  test "shows correct human readable format for announcement types" do
    speech_types = {
      SpeechType::Transcript => "Speech",
      SpeechType::DraftText => "Speech",
      SpeechType::SpeakingNotes => "Speech",
      SpeechType::WrittenStatement => "Statement to parliament",
      SpeechType::OralStatement => "Statement to parliament"
    }

    speech_types.each do |type, expected|
      speech = AnnouncementPresenter.decorate(build(:published_speech, speech_type: type))
      assert_equal expected, speech.display_type
    end

    news_article = AnnouncementPresenter.decorate(build(:published_news_article))
    assert_equal "News article", news_article.display_type
  end
end
