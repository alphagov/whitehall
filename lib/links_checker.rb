class LinksChecker
  attr_accessor :links

  def initialize(links)
    @links = links
    @broken_links = Set.new
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
      end
    end
  end
end
