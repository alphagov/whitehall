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

    def replacement_html_for_admin_link(anchor, &block)
      case anchor['href']
      when ADMIN_ORGANISATION_CIP_PATH
        convert_link_for_corporate_information_page(anchor, $1, $2, &block)
      when ADMIN_WORLDWIDE_ORGANISATION_CIP_PATH
        convert_link_for_worldwide_corporate_information_page(anchor, $1, $2, &block)
      when ADMIN_EDITION_PATH
        edition = Edition.unscoped.find_by(id: $1)
        convert_link_for_edition(anchor, edition, &block)
      else
        replace_bad_link(anchor, &block)
      end
    end

  private

    def convert_link_for_corporate_information_page(anchor, organisation_slug, slug, &block)
      organisation = Organisation.find_by(slug: organisation_slug)
      corporate_info_page = organisation.corporate_information_pages.find(slug)

      convert_link_for_edition(anchor, corporate_info_page, &block)
    end

    def convert_link_for_worldwide_corporate_information_page(anchor, world_org_slug, slug, &block)
      organisation = WorldwideOrganisation.find_by(slug: world_org_slug)
      corporate_info_page = organisation.corporate_information_pages.find(slug)

      convert_link_for_edition(anchor, corporate_info_page, &block)
    end

    def convert_link_for_edition(anchor, edition, options = {})
      new_html = if edition.present? && edition.linkable?
                   anchor
                     .dup
                     .tap { |anchor| anchor['href'] = Whitehall.url_maker.public_document_url(edition, options) }
                     .to_html
                     .html_safe
                 else
                   anchor.inner_text
                 end

      block_given? ? yield(new_html, edition) : new_html
    end

    def replace_bad_link(anchor)
      block_given? ? yield(anchor.inner_text, nil) : anchor.inner_text
    end
  end
end
