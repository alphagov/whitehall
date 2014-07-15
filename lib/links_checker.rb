class LinksChecker
  mattr_accessor :authed_domains
  self.authed_domains = {}

  LOGGER = Logger.new(Rails.root.join('log/broken_link_checks.log'))

  attr_accessor :links, :logger

  def initialize(links, logger=LOGGER)
    @links = links
    @broken_links = Set.new
    @logger = logger
  end

  def broken_links
    @broken_links.to_a
  end

  def run
    hydra = Typhoeus::Hydra.new(max_concurrency: 5)
    links.each do |link|
      hydra.queue request(link)
    end
    hydra.run
  end

  def request(link)
    Typhoeus::Request.new(link, options_for_link(link)).tap do |request|
      request.on_failure do |response|
        @broken_links << link
        logger.info("Broken link found (#{response.code} - #{response.return_message}) #{link}")
      end
    end
  end

private

  def options_for_link(link)
    host = URI.parse(link).host

    if userpwd_for(host)
      default_options.merge(userpwd: userpwd_for(host))
    else
      default_options
    end
  rescue URI::InvalidURIError
    default_options
  end

  def userpwd_for(host)
    LinksChecker.authed_domains[host]
  end

  def default_options
    { followlocation: true, forbid_reuse: true, timeout: 10, connecttimeout: 10 }
  end
end
