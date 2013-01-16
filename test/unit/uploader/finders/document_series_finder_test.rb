require 'test_helper'

class Whitehall::Uploader::Finders::DocumentSeriesFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the document series identified by slug" do
    document_series = create(:document_series)
    assert_equal [document_series], Whitehall::Uploader::Finders::DocumentSeriesFinder.find(document_series.slug, @log, @line_number)
  end

  test "returns empty array if the slug is blank" do
    assert_equal [], Whitehall::Uploader::Finders::DocumentSeriesFinder.find('', @log, @line_number)
  end

  test "does not add an error if the slug is blank" do
    Whitehall::Uploader::Finders::DocumentSeriesFinder.find('', @log, @line_number)
    assert_equal '', @log_buffer.string
  end

  test "returns empty array if the document series can't be found" do
    assert_equal [], Whitehall::Uploader::Finders::DocumentSeriesFinder.find('made-up-document-series-slug', @log, @line_number)
  end

  test "logs a warning if the document series can't be found" do
    Whitehall::Uploader::Finders::DocumentSeriesFinder.find('made-up-document-series-slug', @log, @line_number)
    assert_match /Unable to find Document series with slug 'made-up-document-series-slug'/, @log_buffer.string
  end
end
