module Govspeak
  class AdminLinkReplacer
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
      path = anchor['href']
      edition_path_pattern = Whitehall.edition_route_path_segments.join('|')
      if path[%r{/admin/editions/(\d+)/supporting-pages/([\w-]+)$}]
        policy = Policy.unscoped.find_by_id($1)
        supporting_page = EditionedSupportingPageMapping.find_by_old_supporting_page_id($2).try(:new_supporting_page)
        replacement_html_for_edition_link(anchor, supporting_page, policy_id: policy.document, &block)
      elsif path[%r{/admin/organisations/([\w-]+)/corporate_information_pages/(\d+)$}]
        organisation = Organisation.find_by_slug($1)
        corporate_info_page = organisation.corporate_information_pages.find($2)
        replacement_html_for_edition_link(anchor, corporate_info_page, &block)
      elsif path[%r{/admin/worldwide_organisations/([\w-]+)/corporate_information_pages/(\d+)$}]
        organisation = WorldwideOrganisation.find_by_slug($1)
        corporate_info_page = organisation.corporate_information_pages.find($2)
        replacement_html_for_edition_link(anchor, corporate_info_page, &block)
      elsif path[%r{/admin/(?:#{edition_path_pattern})/(\d+)$}]
        edition = Edition.unscoped.find_by_id($1)
        replacement_html_for_edition_link(anchor, edition, &block)
      else
        replacement_html_for_bad_link(anchor, &block)
      end
    end

    private

    def replacement_html_for_edition_link(anchor, edition, options = {})
      new_html = if edition.present? && edition.linkable?
        anchor.dup.tap do |anchor|
          anchor['href'] = Whitehall.url_maker.public_document_url(edition, options)
        end.to_html.html_safe
      else
        anchor.inner_text
      end

      block_given? ? yield(new_html, edition) : new_html
    end

    def replacement_html_for_bad_link(anchor)
      block_given? ? yield(anchor.inner_text, nil) : anchor.inner_text
    end
  end
end
