# Statsd receives packets over UDP, so even if the daemon isn't running on
# your machine (e.g. in development) everything should work fine
Whitehall.stats_collector =
  Statsd.new(ENV["STATSD_HOST"] || "localhost", 8125).tap do |c|
    c.namespace = (ENV['GOVUK_STATSD_PREFIX'] || 'govuk.app.whitehall').to_s
  end
