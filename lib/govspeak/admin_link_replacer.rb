require 'data_hygiene/govspeak_link_validator'

module Govspeak
  class AdminLinkReplacer
    include EmbeddedContentPatterns

    def initialize(nokogiri_fragment)
      @nokogiri_fragment = nokogiri_fragment
    end

    def replace!(&block)
      @nokogiri_fragment.search('a').each do |anchor|
        next unless DataHygiene::GovspeakLinkValidator.is_internal_admin_link?(anchor['href'])

        replacement_html = replacement_html_for_admin_link(anchor, &block)
        anchor.replace Nokogiri::HTML.fragment(replacement_html)
      end
    end

    def replacement_html_for_admin_link(anchor)
      edition = Whitehall::AdminLinkLookup.find_edition(anchor['href'])

      if edition.present? && edition.linkable?
        public_url = Whitehall.url_maker.public_document_url(edition)
        new_html = convert_link(anchor, public_url)
      else
        new_html = anchor.inner_text
      end

      block_given? ? yield(new_html, edition) : new_html
    end

  private

    def convert_link(anchor, new_url)
      anchor
        .dup
        .tap { |new_anchor| new_anchor['href'] = new_url }
        .to_html
        .html_safe
    end
  end
end
