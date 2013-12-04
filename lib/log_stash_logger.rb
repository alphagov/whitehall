require 'logstash-event'

# Quacking like a Logger (except initialize), this takes normal logger messages but writes
# them out in logstash JSON format. It can also accept log messages as hashes for more
# custom Logstash logging.

class LogStashLogger < Logger
  attr_reader :default_tags

  def initialize(logdev, opts = {})
    # initialize arguments deviate from Logger's to allow for named opts without having
    # to specify shift_ags / shift_size. super method schema is:
    # initialize(logdev, shift_age = 0, shift_size = 1048576)
    super(logdev, opts[:shift_age] || 0, opts[:shift_size] || 1048576)

    @progname     = opts[:progname]     || nil
    @default_tags = opts[:default_tags] || []

    self.formatter = method(:render_entry)
  end

private

  def render_entry(severity, time, progname, log_data)
    if log_data.is_a? String
      log_data = {message: log_data}
    end

    log_data.symbolize_keys!
    message = log_data.delete(:message)
    source  = log_data.delete(:source) || ''
    tags    = default_tags + (log_data.delete(:tags) || [])
    fields  = log_data.reverse_merge({
      message:  message,
      level:    severity,
      progname: progname
    })

    LogStash::Event.new({
      "@timestamp" => time.iso8601,
      "@message" => message,
      "@source" => source,
      "@tags" => tags,
      "@fields" => fields
    }).to_json + "\n"
  end
end
