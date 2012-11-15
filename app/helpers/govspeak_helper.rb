require 'addressable/uri'
require 'delegate'

module GovspeakHelper
  def govspeak_to_html(govspeak, images=[])
    wrapped_in_govspeak_div(bare_govspeak_to_html(govspeak, images))
  end

  def govspeak_edition_to_html(edition)
    wrapped_in_govspeak_div(bare_govspeak_edition_to_html(edition))
  end

  def bare_govspeak_edition_to_html(edition)
    images = edition.respond_to?(:images) ? edition.images : []
    partially_processed_govspeak = edition_body_with_attachments_and_alt_format_information(edition)
    bare_govspeak_to_html(partially_processed_govspeak, images)
  end

  def govspeak_headers(govspeak, level = 2)
    level = (level..level) unless level.is_a?(Range)
    build_govspeak_document(govspeak).headers.select do |header|
      level.cover?(header.level)
    end
  end

  class OrphanedHeadingError < StandardError
    attr_reader :heading
    def initialize(heading)
      @heading = heading
      super("Parent heading missing for: #{heading}")
    end
  end

  def govspeak_header_hierarchy(govspeak)
    headers = []
    govspeak_headers(govspeak, 2..3).each do |header|
      if header.level == 2
        headers << {header: header, children: []}
      elsif header.level == 3
        raise OrphanedHeadingError.new(header.text) if headers.none?
        headers.last[:children] << header
      end
    end
    headers
  end

  private

  def bare_govspeak_to_html(govspeak, images = [])
    govspeak_to_html_with_replaced_admin_links(govspeak, images)
  end

  def wrapped_in_govspeak_div(html_string)
    content_tag(:div, html_string.html_safe, class: 'govspeak')
  end

  def govspeak_to_html_with_replaced_admin_links(govspeak, images = [], &block)
    markup_to_nokogiri_doc(govspeak, images).tap do |nokogiri_doc|
      replace_internal_admin_links_in nokogiri_doc, &block
    end.to_html.html_safe
  end

  def replace_internal_admin_links_in(nokogiri_doc)
    nokogiri_doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(uri = anchor['href'])

      if is_admin_organisation_uri?(uri)
        organisation, corporate_information_page, document_series = find_organisation_and_related_entities_from_uri(uri)
        replacement_html = replacement_html_for_organisation_and_related_entities(anchor, organisation, corporate_information_page, document_series)
      else
        edition, supporting_page = find_edition_and_supporting_page_from_uri(uri)
        replacement_html = replacement_html_for(anchor, edition, supporting_page)
      end
      replacement_html = yield(replacement_html, edition) if block_given?

      anchor.replace Nokogiri::HTML.fragment(replacement_html)
    end
  end

  def replacement_html_for(anchor, edition, supporting_page)
    if edition.present? && edition.linkable?
      anchor.dup.tap do |anchor|
        anchor['href'] = rewritten_href_for_edition(edition, supporting_page)
      end.to_html.html_safe
    else
      anchor.inner_text
    end
  end

  def replacement_html_for_organisation_and_related_entities(anchor, organisation, corporate_information_page, document_series)
    if organisation.present?
      anchor.dup.tap do |anchor|
        anchor['href'] = rewritten_href_for_organisation_and_related_entities(organisation, corporate_information_page, document_series)
      end.to_html.html_safe
    else
      anchor.inner_text
    end
  end

  def markup_to_nokogiri_doc(govspeak, images = [])
    govspeak = build_govspeak_document(govspeak, images)
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    doc.fragment(govspeak.to_html)
  end

  def govspeak_with_attachments_and_alt_format_information(govspeak, attachments = [], alternative_format_contact_email = nil)
    govspeak.gsub(/\n{0,2}^!@([0-9]+)\s*/) do
      if attachment = attachments[$1.to_i - 1]
        "\n\n" + render(partial: "documents/attachment.html.erb", object: AssetHostDecorator.new(attachment), locals: {alternative_format_contact_email: alternative_format_contact_email}) + "\n\n"
      else
        "\n\n"
      end
    end
  end

  def edition_body_with_attachments_and_alt_format_information(edition)
    attachments = edition.respond_to?(:attachments) ? edition.attachments : []
    govspeak_with_attachments_and_alt_format_information(edition.body, attachments, edition.alternative_format_contact_email)
  end

  def is_internal_admin_link?(href)
    return false unless href.is_a? String
    begin
      uri = Addressable::URI.parse(href)
    rescue Addressable::URI::InvalidURIError
      return false
    end

    admin_path = [Whitehall.router_prefix, "admin"].join("/")

    if %w(http https).include?(uri.scheme)
      truncated_link_uri = [normalise_host(uri.host), uri.path.split("/")[1,2]].join("/")
      truncated_host_uri = [normalise_host(request.host) + admin_path].join("/")
      truncated_link_uri == truncated_host_uri
    else
      uri.path.start_with?(admin_path)
    end
  end

  def is_admin_organisation_uri?(href)
    return false unless href.is_a? String
    begin
      uri = Addressable::URI.parse(href)
    rescue Addressable::URI::InvalidURIError
      return false
    end

    admin_organisation_path = [Whitehall.router_prefix, "admin", "organisations"].join("/")

    if %w(http https).include?(uri.scheme)

      truncated_link_uri = [normalise_host(uri.host), uri.path.split("/")[1,3]].join("/")
      truncated_host_uri = [normalise_host(request.host) + admin_organisation_path].join("/")
      truncated_link_uri == truncated_host_uri
    else
      uri.path.start_with?(admin_organisation_path)
    end
  end

  def find_edition_and_supporting_page_from_uri(uri)
    edition_path_pattern = Whitehall.edition_route_path_segments.join("|")
    edition_id, supporting_page_id = nil
    if uri[%r{/admin/editions/(\d+)/supporting-pages/([\w-]+)$}]
      edition_id, supporting_page_id = $1, $2
    elsif uri[%r{/admin/(?:#{edition_path_pattern})/(\d+)$}]
      edition_id = $1
    end
    edition = edition_id && Edition.send(:with_exclusive_scope) { Edition.where(id: edition_id).first }
    supporting_page = edition && supporting_page_id && edition.supporting_pages.where(slug: supporting_page_id).first
    [edition, supporting_page]
  end

  def find_organisation_and_related_entities_from_uri(uri)
    organisation_id, corporate_information_page_id, document_series_id = nil, nil, nil
    if uri[%r{/admin/organisations/([\w-]+)$}]
      organisation_id = $1
    elsif uri[%r{/admin/organisations/([\w-]+)/corporate_information_pages/([\w-]+)$}]
      organisation_id, corporate_information_page_id = $1, $2
    elsif uri[%r{/admin/organisations/([\w-]+)/corporate_information_pages/([\w-]+)/edit$}]
      organisation_id, corporate_information_page_id = $1, $2
    elsif uri[%r{/admin/organisations/([\w-]+)/document_series/([\w-]+)$}]
      organisation_id, document_series_id = $1, $2
    elsif uri[%r{/admin/organisations/([\w-]+)/document_series/([\w-]+)/edit$}]
      organisation_id, document_series_id = $1, $2
    end
    organisation = organisation_id && Organisation.where(slug: organisation_id).first
    corporate_information_page = organisation && corporate_information_page_id && organisation.corporate_information_pages.for_slug(corporate_information_page_id)
    document_series = organisation && document_series_id && organisation.document_series.where(slug: document_series_id).first
    [organisation, corporate_information_page, document_series]
  end

  def rewritten_href_for_edition(edition, supporting_page)
    if supporting_page
      public_supporting_page_url(edition, supporting_page)
    else
      public_document_url(edition)
    end
  end

  def rewritten_href_for_organisation_and_related_entities(organisation, corporate_information_page, document_series)
    if organisation && corporate_information_page
      organisation_corporate_information_page_url(organisation, corporate_information_page)
    elsif organisation && document_series
      organisation_document_series_url(organisation, document_series)
    else
      organisation_url(organisation)
    end
  end

  def normalise_host(host)
    Whitehall.public_host_for(host) || host
  end

  def build_govspeak_document(govspeak, images = [])
    request_host = respond_to?(:request) ? request.host : nil
    hosts = [request_host] + Whitehall.admin_hosts + Whitehall.public_hosts
    Govspeak::Document.new(govspeak, document_domains: hosts).tap do |document|
      document.images = images.map {|i| AssetHostDecorator.new(i)}
    end
  end

  class AssetHostDecorator < SimpleDelegator
    def url(*args)
      (Whitehall.asset_host || "") + super(*args)
    end
  end
end
