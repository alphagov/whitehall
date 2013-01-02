require 'test_helper'

class Whitehall::Uploader::Finders::SpeechTypeFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the speech type found by the slug" do
    assert_equal SpeechType::Transcript, Whitehall::Uploader::Finders::SpeechTypeFinder.find('transcript', @log, @line_number)
  end

  test "returns nil if the speech type can't be determined" do
    assert_nil Whitehall::Uploader::Finders::SpeechTypeFinder.find('made-up-speech-type', @log, @line_number)
  end

  test "logs a warning if the speech type can't be determined" do
    Whitehall::Uploader::Finders::SpeechTypeFinder.find('made-up-speech-type-slug', @log, @line_number)
    assert_match /Unable to find Speech type with slug 'made-up-speech-type-slug'/, @log_buffer.string
  end

  test 'uses the ImportedAwaitingType type for a blank slug' do
    assert_equal SpeechType::ImportedAwaitingType, Whitehall::Uploader::Finders::SpeechTypeFinder.find('', @log, @line_number)
  end
end
