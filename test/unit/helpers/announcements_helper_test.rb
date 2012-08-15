require 'test_helper'

class AnnouncementsHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "shows correct human readable format for speech types" do
    speech_types = {
      SpeechType::Transcript => "Speech",
      SpeechType::DraftText => "Speech",
      SpeechType::SpeakingNotes => "Speech",
      SpeechType::WrittenStatement => "Statement to parliament",
      SpeechType::OralStatement => "Statement to parliament"
    }

    speech_types.each do |type, expected|
      speech = create(:published_speech, speech_type: type)

      assert_equal expected, announcement_type(speech)
    end
  end
end
