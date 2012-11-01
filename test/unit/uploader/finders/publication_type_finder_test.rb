require 'test_helper'

class Whitehall::Uploader::Finders::PublicationTypeFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the publication type found by the slug" do
    assert_equal PublicationType::CircularLetterOrBulletin, Whitehall::Uploader::Finders::PublicationTypeFinder.find('circulars-letters-and-bulletins', @log, @line_number)
  end

  test "returns nil if the publication type can't be determined" do
    assert_nil Whitehall::Uploader::Finders::PublicationTypeFinder.find('made-up-publication-type', @log, @line_number)
  end

  test "logs a warning if the publication type can't be determined" do
    Whitehall::Uploader::Finders::PublicationTypeFinder.find('made-up-publication-type-slug', @log, @line_number)
    assert_match /Unable to find Publication type with slug 'made-up-publication-type-slug'/, @log_buffer.string
  end
end