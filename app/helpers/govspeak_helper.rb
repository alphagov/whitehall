require 'delegate'

module GovspeakHelper
  include ::Govspeak::ContactsExtractorHelpers
  include Rails.application.routes.url_helpers
  include LocalisedUrlPathHelper

  BARCHART_REGEXP = /{barchart(.*?)}/
  SORTABLE_REGEXP = /{sortable}/
  FRACTION_REGEXP = /\[Fraction:(?<numerator>[0-9a-zA-Z]+)\/(?<denominator>[0-9a-zA-Z]+)\]/

  def govspeak_to_html(govspeak, images = [], options = {})
    wrapped_in_govspeak_div(bare_govspeak_to_html(govspeak, images, options))
  end

  def govspeak_edition_to_html(edition)
    return '' unless edition

    wrapped_in_govspeak_div(bare_govspeak_edition_to_html(edition))
  end

  def govspeak_with_attachments_to_html(body, attachments = [], alternative_format_contact_email = nil)
    wrapped_in_govspeak_div(bare_govspeak_with_attachments_to_html(body, attachments, alternative_format_contact_email))
  end

  def bare_govspeak_edition_to_html(edition)
    images = edition.respond_to?(:images) ? edition.images : []
    partially_processed_govspeak = edition_body_with_attachments_and_alt_format_information(edition)
    bare_govspeak_to_html(partially_processed_govspeak, images)
  end

  def bare_govspeak_with_attachments_to_html(body, attachments = [], alternative_format_contact_email = nil)
    partially_processed_govspeak = govspeak_with_attachments_and_alt_format_information(body, attachments, alternative_format_contact_email)
    bare_govspeak_to_html(partially_processed_govspeak, [])
  end

  def govspeak_headers(govspeak, level = (2..2))
    build_govspeak_document(govspeak).headers.select do |header|
      level.cover?(header.level)
    end
  end

  def html_attachment_govspeak_headers(attachment)
    govspeak_headers(attachment.govspeak_content_body).tap do |headers|
      if attachment.manually_numbered_headings?
        headers.each { |header|
          header.text = header.text.gsub(/^(\d+.?\d*)\s*/, '<span class="heading-number">\1</span> ').html_safe
        }
      end
    end
  end

  def html_attachment_govspeak_headers_html(attachment)
    content_tag(:ol, class: ('unnumbered' if attachment.manually_numbered_headings?)) do
      html_attachment_govspeak_headers(attachment).reduce('') do |html, header|
        css_class = header_contains_manual_numbering?(header) ? 'numbered' : nil
        html << content_tag(:li, link_to(header.text, "##{header.id}"), class: css_class)
      end.html_safe
    end
  end

  def header_contains_manual_numbering?(header)
    header.text.include?('<span class="heading-number">')
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
        headers << { header: header, children: [] }
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

  def fraction_image(numerator, denominator)
    denominator.downcase! if %w{X Y}.include? denominator
    if numerator.present? && denominator.present? && Rails.application.assets.find_asset("fractions/#{numerator}_#{denominator}.png")
      asset_path("fractions/#{numerator}_#{denominator}.png", host: Whitehall.public_asset_host)
    end
  end

  def govspeak_options_for_html_attachment(attachment)
    numbering_method = attachment.manually_numbered_headings? ? :manual : :auto
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
    govspeak.gsub(Govspeak::EmbeddedContentPatterns::CONTACT) do
      if contact = Contact.find_by(id: $1)
        render(partial: 'contacts/contact', locals: { contact: contact, heading_tag: heading_tag }, formats: ["html"])
      else
        ''
      end
    end
  end

  def render_embedded_fractions(govspeak)
    return govspeak if govspeak.blank?
    govspeak.gsub(GovspeakHelper::FRACTION_REGEXP) do |_match|
      if $1.present? && $2.present?
        render(partial: 'shared/govspeak_fractions', formats: [:html], locals: { numerator: $1, denominator: $2 })
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

  def replace_internal_admin_links_in(nokogiri_doc, &block)
    Govspeak::AdminLinkReplacer.new(nokogiri_doc).replace!(&block)
  end

  def add_class_to_last_blockquote_paragraph(nokogiri_doc)
    nokogiri_doc.css('blockquote p:last-child').map do |el|
      el[:class] = 'last-child'
    end
  end

  def add_heading_numbers(nokogiri_doc)
    h2_depth = 0
    h3_depth = 0
    nokogiri_doc.css('h2, h3').each do |el|
      if el.name == 'h2'
        h3_depth = 0
        number = "#{h2_depth += 1}."
      else
        number = "#{h2_depth}.#{h3_depth += 1}"
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
        "\n\n" + render(partial: "documents/attachment", formats: :html, object: attachment, locals: { alternative_format_contact_email: alternative_format_contact_email }) + "\n\n"
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

  def build_govspeak_document(govspeak, images = [])
    hosts = [Whitehall.admin_host, Whitehall.public_host]
    Govspeak::Document.new(govspeak, document_domains: hosts).tap do |document|
      document.images = images.map { |i| AssetHostDecorator.new(i) }
    end
  end

  class AssetHostDecorator < SimpleDelegator
    def url(*args)
      Whitehall.public_asset_host + super
    end
  end
end
