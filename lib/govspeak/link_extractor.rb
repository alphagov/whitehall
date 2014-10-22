module Govspeak
  class LinkExtractor
    def initialize(govspeak)
      @govspeak = govspeak
    end

    def links
      @links ||= convert_paths_to_urls(extract_links)
    end

  private

    def convert_paths_to_urls(links)
      links.map {|link| link.starts_with?('/') ? "#{Whitehall.public_root}#{link}" : link }
    end

    def extract_links
      processed_govspeak.css('a:not([href^="mailto"])').css('a:not([href^="#"])').map { |link| link['href'] }
    end

    def processed_govspeak
      doc = Nokogiri::HTML::Document.new
      doc.encoding = "UTF-8"

      doc.fragment(Govspeak::Document.new(@govspeak).to_html).tap do |fragment|
        Govspeak::AdminLinkReplacer.new(fragment).replace!
      end
    end
  end
end
