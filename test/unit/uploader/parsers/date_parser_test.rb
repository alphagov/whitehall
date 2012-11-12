require "fast_test_helper"

require "whitehall/uploader/parsers/date_parser"

class Whitehall::Uploader::Parsers::DateParserTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the date" do
    assert_equal Date.parse('2012-11-01'), Whitehall::Uploader::Parsers::DateParser.parse('11/01/2012', @log, @line_number)
  end

  test "can parse dates in dd-MMM-yy format" do
    assert_equal Date.parse('2012-05-23'), Whitehall::Uploader::Parsers::DateParser.parse('23-May-12', @log, @line_number)
  end

  test "can parse dates in dd-MMM-yyyy format" do
    assert_equal Date.parse('2013-07-10'), Whitehall::Uploader::Parsers::DateParser.parse('10-Jul-2013', @log, @line_number)
  end

  test "can parse dates in yyyy-mm-dd format" do
    assert_equal Date.parse('2001-10-31'), Whitehall::Uploader::Parsers::DateParser.parse('2001-10-31', @log, @line_number)
  end

  test "returns nil if passed string is empty" do
    assert_nil Whitehall::Uploader::Parsers::DateParser.parse('', @log, @line_number)
  end

  test "returns nil if date cannot be parsed" do
    assert_nil Whitehall::Uploader::Parsers::DateParser.parse('11/012012', @log, @line_number)
  end

  test "logs a warning if the date cannot be parsed" do
    Whitehall::Uploader::Parsers::DateParser.parse('11/012012', @log, @line_number)
    assert_match /Unable to parse the date '11\/012012'/, @log_buffer.string
  end
end