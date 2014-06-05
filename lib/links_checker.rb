class LinksChecker
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
    links.each do |link|
      request(link).run
    end
  end

  def request(link)
    Typhoeus::Request.new(link, followlocation: true).tap do |request|
      request.on_failure do |response|
        @broken_links << link
        logger.info("Broken link found (#{response.code} - #{response.return_message}) #{link}")
      end
    end
  end
end
