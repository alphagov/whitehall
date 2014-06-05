module Govspeak
  class LinkExtractor
    def initialize(govspeak)
      @govspeak = govspeak
    end

    def links
      @links ||= extract_links
    end

  private

    def extract_links
      Nokogiri::HTML.parse(html_from_govspeak).css('a').map { |link| link['href'] }
    end

    def html_from_govspeak
      Govspeak::Document.new(@govspeak).to_html
    end
  end
end
