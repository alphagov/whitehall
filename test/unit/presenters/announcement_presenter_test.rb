require "test_helper"

class AnnouncementPresenterTest < PresenterTestCase
  test "shows correct human readable format for speeches" do
    speech_types = {
      SpeechType::Transcript => "Speech",
      SpeechType::DraftText => "Speech",
      SpeechType::SpeakingNotes => "Speech",
      SpeechType::WrittenStatement => "Statement to Parliament",
      SpeechType::OralStatement => "Statement to Parliament"
    }

    speech_types.each do |type, expected|
      speech = AnnouncementPresenter.new(Speech.new(speech_type: type), @view_context)
      assert_equal expected, speech.display_type
    end
  end

  test 'shows correct human readable format for news articles' do
    news_article_types = {
      NewsArticleType::NewsStory => "News story",
      NewsArticleType::PressRelease => "Press release",
      NewsArticleType::GovernmentResponse => "Government response"
    }

    news_article_types.each do |type, expected|
      news_article = AnnouncementPresenter.new(NewsArticle.new(news_article_type: type), @view_context)
      assert_equal expected, news_article.display_type
    end
  end

  test "adds field of operations to the as_hash if exists" do
    document = stub_record(:document)
    document.stubs(:to_param).returns('some-doc')
    organisation = stub_record(:organisation, name: "Ministry of Defence", organisation_type: OrganisationType.other)
    operational_field = stub_record(:operational_field, name: "Name")
    fatality_notice = stub_record(:fatality_notice,
      document: document,
      public_timestamp: Time.zone.now,
      organisations: [organisation],
      operational_field: operational_field)
    # TODO: perhaps rethink edition factory, so this apparent duplication
    # isn't neccessary
    fatality_notice.stubs(:organisations).returns([organisation])
    hash = AnnouncementPresenter.new(fatality_notice, @view_context).as_hash
    assert hash[:field_of_operation]
  end
end
