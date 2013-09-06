require 'addressable/uri'
require 'delegate'

module GovspeakHelper
  EMBEDDED_CONTACT_REGEXP = /\[Contact\:([0-9]+)\]/
  BARCHART_REGEXP = /{barchart(.*?)}/
  SORTABLE_REGEXP = /{sortable}/
  FRACTION_REGEXP = /\[Fraction:(?<numerator>[0-9a-zA-Z]+)\/(?<denominator>[0-9a-zA-Z]+)\]/

  def govspeak_to_html(govspeak, images=[], options={})
    wrapped_in_govspeak_div(bare_govspeak_to_html(govspeak, images, options))
  end

  def govspeak_edition_to_html(edition)
    wrapped_in_govspeak_div(bare_govspeak_edition_to_html(edition))
  end

  def govspeak_with_attachments_to_html(body, attachments = [])
    wrapped_in_govspeak_div(bare_govspeak_with_attachments_to_html(body, attachments))
  end

  def bare_govspeak_edition_to_html(edition)
    images = edition.respond_to?(:images) ? edition.images : []
    partially_processed_govspeak = edition_body_with_attachments_and_alt_format_information(edition)
    bare_govspeak_to_html(partially_processed_govspeak, images)
  end

  def bare_govspeak_with_attachments_to_html(body, attachments = [])
    partially_processed_govspeak = govspeak_with_attachments_and_alt_format_information(body, attachments)
    bare_govspeak_to_html(partially_processed_govspeak, [])
  end

  def govspeak_headers(govspeak, level=(2..2))
    build_govspeak_document(govspeak).headers.select do |header|
      level.cover?(header.level)
    end
  end

  def html_version_govspeak_headers(html_version)
    govspeak_headers(html_version.body).tap do |headers|
      if html_version.manually_numbered?
        headers.each { |header| header.text = header.text.gsub(/^(\d+.?\d*\s*)/, '') }
      end
    end
  end

  def govspeak_embedded_contacts(govspeak)
    return [] if govspeak.blank?
    # scan yields an array of capture groups for each match
    # so "[Contact:1] is now [Contact:2]" => [["1"], ["2"]]
    govspeak.scan(GovspeakHelper::EMBEDDED_CONTACT_REGEXP).map { |capture|
      contact_id = capture.first
      Contact.find_by_id(contact_id)
    }.compact
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

  def inline_attachment_code_tags(number)
    content_tag(:code, "!@#{number}") <<
    ' or '.html_safe <<
    content_tag(:code, "[InlineAttachment:#{number}]")
  end

  def govspeak_options_for_html_version(html_version)
    numbering_method = html_version.manually_numbered? ? :manual : :auto
    { heading_numbering: numbering_method, contact_heading_tag: 'h4' }
  end

  private

  def remove_extra_quotes_from_blockquotes(govspeak)
    Whitehall::ExtraQuoteRemover.new.remove(govspeak)
  end

  def wrapped_in_govspeak_div(html_string)
    content_tag(:div, html_string.html_safe, class: 'govspeak')
  end

  def bare_govspeak_to_html(govspeak, images = [], options = {}, &block)
    # pre-processors
    govspeak = remove_extra_quotes_from_blockquotes(govspeak)
    govspeak = render_embedded_contacts(govspeak, options[:contact_heading_tag])
    govspeak = render_embedded_fractions(govspeak)
    govspeak = set_classes_for_charts(govspeak)
    govspeak = set_classes_for_sortable_tables(govspeak)

    markup_to_nokogiri_doc(govspeak, images).tap do |nokogiri_doc|
      # post-processors
      replace_internal_admin_links_in(nokogiri_doc, &block)
      add_class_to_last_blockquote_paragraph(nokogiri_doc)
      if options[:heading_numbering] == :auto
        add_heading_numbers(nokogiri_doc)
      elsif options[:heading_numbering] == :manual
        add_manual_heading_numbers(nokogiri_doc)
      end
    end.to_html.html_safe
  end

  def render_embedded_contacts(govspeak, heading_tag)
    return govspeak if govspeak.blank?
    heading_tag ||= 'h3'
    govspeak.gsub(GovspeakHelper::EMBEDDED_CONTACT_REGEXP) do
      if contact = Contact.find_by_id($1)
        render(partial: 'contacts/contact', locals: { contact: contact, heading_tag: heading_tag }, formats: ["html"])
      else
        ''
      end
    end
  end

  def render_embedded_fractions(govspeak)
    return govspeak if govspeak.blank?
    govspeak.gsub(GovspeakHelper::FRACTION_REGEXP) do |match|
      if $1.present? && $2.present?
        "<span class=\"fraction\"><sup>#{$1}</sup>&frasl;<sub>#{$2}</sub></span>"
      else
        ''
      end
    end
  end

  def set_classes_for_sortable_tables(govspeak)
    return govspeak if govspeak.blank?

    govspeak.gsub(GovspeakHelper::SORTABLE_REGEXP, "{:.sortable}")
  end

  def set_classes_for_charts(govspeak)
    return govspeak if govspeak.blank?

    govspeak.gsub(GovspeakHelper::BARCHART_REGEXP) do
      stacked = '.mc-stacked' if $1.include? 'stacked'
      compact = '.compact' if $1.include? 'compact'
      negative = '.mc-negative' if $1.include? 'negative'

      [
       '{:',
       '.js-barchart-table',
       stacked,
       compact,
       negative,
       '.mc-auto-outdent',
       '}'
      ].join(' ')
    end
  end

  def replace_internal_admin_links_in(nokogiri_doc)
    nokogiri_doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(uri = anchor['href'])

      edition, supporting_page = find_edition_and_supporting_page_from_uri(uri)
      replacement_html = replacement_html_for(anchor, edition, supporting_page)
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

  def add_class_to_last_blockquote_paragraph(nokogiri_doc)
    nokogiri_doc.css('blockquote p:last-child').map do |el|
      el[:class] = 'last-child'
    end
  end

  def add_heading_numbers(nokogiri_doc)
    h2_depth, h3_depth = 0, 0
    nokogiri_doc.css('h2, h3').each do |el|
      number = if el.name == 'h2'
        "#{h2_depth+=1}."
      else
        "#{h2_depth}.#{h3_depth+=1}"
      end
      el.inner_html = el.document.fragment(%{<span class="number">#{number} </span>#{el.inner_html}})
    end
  end

  def add_manual_heading_numbers(nokogiri_doc)
    nokogiri_doc.css('h2, h3').each do |el|
      if number = extract_number_from_heading(el)
        heading_without_number = el.inner_html.gsub(number, '')
        el.inner_html = el.document.fragment(%{<span class="number">#{number} </span>#{heading_without_number}})
      end
    end
  end

  def extract_number_from_heading(nokogiri_el)
    nokogiri_el.inner_text[/^\d+.?\d*/]
  end

  def markup_to_nokogiri_doc(govspeak, images = [])
    govspeak = build_govspeak_document(govspeak, images)
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    doc.fragment(govspeak.to_html)
  end

  def govspeak_with_attachments_and_alt_format_information(govspeak, attachments = [], alternative_format_contact_email = nil)
    govspeak = govspeak.gsub(/\n{0,2}^!@([0-9]+)\s*/) do
      if attachment = attachments[$1.to_i - 1]
        "\n\n" + render(partial: "documents/attachment", formats: :html, object: attachment, locals: {alternative_format_contact_email: alternative_format_contact_email}) + "\n\n"
      else
        "\n\n"
      end
    end
    govspeak.gsub(/\[InlineAttachment:([0-9]+)\]/) do
      if attachment = attachments[$1.to_i - 1]
        render(partial: "documents/inline_attachment", formats: :html, locals: { attachment: attachment })
      else
        ""
      end
    end
  end

  def edition_body_with_attachments_and_alt_format_information(edition)
    attachments = edition.allows_attachments? ? edition.attachments : []
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

  def find_edition_and_supporting_page_from_uri(uri)
    edition_path_pattern = Whitehall.edition_route_path_segments.join("|")
    edition_id, supporting_page_id = nil
    if uri[%r{/admin/editions/(\d+)/supporting-pages/([\w-]+)$}]
      edition_id, supporting_page_id = $1, $2
    elsif uri[%r{/admin/(?:#{edition_path_pattern})/(\d+)$}]
      edition_id = $1
    end
    edition = edition_id && Edition.send(:with_exclusive_scope) { Edition.where(id: edition_id).first }
    supporting_page = supporting_page_id && edition && edition.supporting_pages.where(id: supporting_page_id).first
    [edition, supporting_page]
  end

  def rewritten_href_for_edition(edition, supporting_page)
    if supporting_page
      public_supporting_page_url(edition, supporting_page)
    else
      public_document_url(edition)
    end
  end

  def normalise_host(host)
    Whitehall.public_host_for(host) || host
  end

  def build_govspeak_document(govspeak, images = [])
    request_host = respond_to?(:request) ? request.host : nil
    hosts = [request_host] + Whitehall.admin_hosts + Whitehall.public_hosts
    Govspeak::Document.new(govspeak, document_domains: hosts).tap do |document|
      document.images = images.map { |i| AssetHostDecorator.new(i) }
    end
  end

  class AssetHostDecorator < SimpleDelegator
    def url(*args)
      (Whitehall.asset_host || "") + super(*args)
    end
  end
end
