require "fast_test_helper"
require "whitehall/uploader"

class Whitehall::Uploader::Parsers::OldUrlParserTest < ActiveSupport::TestCase
  def setup
    @log = stub_everything
    @line_number = 1
  end

  test "a simple url is just converted to a singular array" do
    assert_equal ["http://example.com"], Whitehall::Uploader::Parsers::OldUrlParser.parse('http://example.com', @log, @line_number)
  end

  test "a json array is converted to an array" do
    parsed = Whitehall::Uploader::Parsers::OldUrlParser.parse('["http://example.com/1","http://example.com/2"]', @log, @line_number)
    assert_equal ["http://example.com/1", "http://example.com/2"], parsed
  end

  test "returns empty array if passed string is empty" do
    assert_equal [], Whitehall::Uploader::Parsers::OldUrlParser.parse('', @log, @line_number)
    assert_equal [], Whitehall::Uploader::Parsers::OldUrlParser.parse(' ', @log, @line_number)
  end

  test "returns empty array if old url json cannot be parsed" do
    assert_equal [], Whitehall::Uploader::Parsers::OldUrlParser.parse('[]bad json', @log, @line_number)
  end

  test "logs an error if the old url json cannot be parsed" do
    @log.expects(:error).with(includes(%q{Unable to parse the old url '[]bad json'}), @line_number)
    Whitehall::Uploader::Parsers::OldUrlParser.parse('[]bad json', @log, @line_number)
  end
end
