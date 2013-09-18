require 'test_helper'
require_relative '../importer_test_logger'

class Whitehall::Uploader::Finders::PublicationTypeFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = ImporterTestLogger.new(@log_buffer)
    @line_number = 1
  end

  def find(slug)
    Whitehall::Uploader::Finders::PublicationTypeFinder.find(slug, @log, @line_number)
  end

  test "returns the publication type found by the slug" do
    assert_equal PublicationType::Correspondence, find('correspondence')
  end

  test "returns nil if the publication type can't be determined" do
    assert_nil find('made-up-publication-type')
  end

  test "logs a warning if the publication type can't be determined" do
    find('made-up-publication-type-slug')
    assert_match /Unable to find Publication type with slug 'made-up-publication-type-slug'/, @log_buffer.string
  end

  test 'uses the ImportedAwaitingType type for a blank slug' do
    assert_equal PublicationType::ImportedAwaitingType, find('')
  end

  test 'uses the ImportedAwaitingType type for a nil slug' do
    assert_equal PublicationType::ImportedAwaitingType, find(nil)
  end
end
