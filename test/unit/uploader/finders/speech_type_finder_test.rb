require 'test_helper'
require 'support/importer_test_logger'

class Whitehall::Uploader::Finders::SpeechTypeFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = ImporterTestLogger.new(@log_buffer)
    @line_number = 1
  end

  def find(slug)
Whitehall::Uploader::Finders::SpeechTypeFinder.find(slug, @log, @line_number)
  end

  test "returns the speech type found by the slug" do
    assert_equal SpeechType::Transcript, find('transcript')
  end

  test "returns nil if the speech type can't be determined" do
    assert_nil find('made-up-speech-type')
  end

  test "logs a warning if the speech type can't be determined" do
    find('made-up-speech-type-slug')
    assert_match /Unable to find Speech type with slug 'made-up-speech-type-slug'/, @log_buffer.string
  end

  test 'uses the ImportedAwaitingType type for a blank slug' do
    assert_equal SpeechType::ImportedAwaitingType, find('')
  end

  test 'uses the ImportedAwaitingType type for a nil slug' do
    assert_equal SpeechType::ImportedAwaitingType, find(nil)
  end
end
