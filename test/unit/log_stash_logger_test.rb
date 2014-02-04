require 'fast_test_helper'
require 'log_stash_logger'
require 'timecop'
require 'active_support/all'

class LogStashLoggerTest < ActiveSupport::TestCase
  attr_reader :stream_writer, :stream_reader

  def initialize(*_)
    super
    Time.zone = "GMT" if Time.zone.nil?
  end

  def setup
    @stream_reader, @stream_writer = IO.pipe
  end

  def teardown
    [stream_reader, stream_writer].each { | io | io.close unless io.closed? }
  end

  def log_entries
    @log_entries ||= get_logged_lines.map { |line| JSON.parse(line) }
  end

  def get_logged_lines
    stream_writer.close
    lines = stream_reader.each_line.to_a
    stream_reader.close
    lines
  end

  def subject(opts = {})
    @subject ||= LogStashLogger.new(stream_writer, opts)
  end

  test "Timestamp is applied" do
    Timecop.freeze do
      subject.warn "some error"
      assert_equal Time.zone.now.iso8601, log_entries.last["@timestamp"]
    end
  end

  test "Log level is recorded as @fields.level" do
    subject.warn "This is a warn level error"
    subject.error "This is an error level message"

    assert_equal "WARN",  log_entries[0]["@fields"]["level"]
    assert_equal "ERROR", log_entries[1]["@fields"]["level"]
  end

  test "Progname is recorded as @fields.progname" do
    subject(progname: "Whitehall").info("some message")
    assert_equal "Whitehall", log_entries.last["@fields"]["progname"]
  end

### When logged thing is a message string

  test "When logged thing is a message string, @message and @fields.message are the given string" do
    subject.info "This is an error"
    assert_equal "This is an error", log_entries.last["@message"]
    assert_equal "This is an error", log_entries.last["@fields"]["message"]
  end

  test "When logged thing is a message string, @tags are the default tags for that logger instance" do
    subject(default_tags: ['dogtag', 'labeltag']).error("Some error")
    assert_equal ['dogtag', 'labeltag'], log_entries.last["@tags"]
  end

### When logged thing is a hash

  test "When logged thing is a hash, message is logged" do
    subject.error(message: "This is a message")

    assert_equal "This is a message", log_entries.last["@message"]
    assert_equal "This is a message", log_entries.last["@fields"]["message"]
  end

  test "When logged thing is a hash, given tags are merged with default tags and logged" do
    subject(default_tags: ["dogtag"]).warn(tags: ["labeltag"])

    assert_equal ["dogtag", "labeltag"], log_entries.last["@tags"]
  end

  test "When logged thing is a hash, given source is logged" do
    subject.warn(source: "http://www.example.com")

    assert_equal "http://www.example.com", log_entries.last["@source"]
  end

  test "When logged thing is a hash, any unknown fields are logged in @fields" do
    subject.warn(wombats: "are not wombles")

    assert_equal "are not wombles", log_entries.last["@fields"]["wombats"]
  end
end
