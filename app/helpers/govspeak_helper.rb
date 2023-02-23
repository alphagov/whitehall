require "delegate"

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
    return "" unless edition

    wrapped_in_govspeak_div(bare_govspeak_edition_to_html(edition))
  end

  def govspeak_with_attachments_to_html(body, attachments = [], alternative_format_contact_email = nil)
    wrapped_in_govspeak_div(bare_govspeak_with_attachments_to_html(body, attachments, alternative_format_contact_email))
  end

  def bare_govspeak_edition_to_html(edition)
    images = edition.respond_to?(:images) ? edition.images : []
    allowed_elements = edition.allows_inline_attachments? ? %w[details] : []
    partially_processed_govspeak = edition_body_with_attachments_and_alt_format_information(edition)
    bare_govspeak_to_html(partially_processed_govspeak, images, allowed_elements:)
  end

  def bare_govspeak_with_attachments_to_html(body, attachments = [], alternative_format_contact_email = nil)
    partially_processed_govspeak = govspeak_with_attachments_and_alt_format_information(body, attachments, alternative_format_contact_email)
    bare_govspeak_to_html(partially_processed_govspeak, [], allowed_elements: %w[details])
  end

  def govspeak_headers(govspeak, level = (2..2))
    build_govspeak_document(govspeak).headers.select do |header|
      level.cover?(header.level)
    end
  end

  def html_attachment_govspeak_headers(attachment)
    govspeak_headers(attachment.govspeak_content_body).tap do |headers|
      if attachment.manually_numbered_headings?
        headers.each do |header|
          header.text = header.text.gsub(/^(\d+.?[^\s]*)\s*/, '<span class="heading-number">\1</span> ').html_safe
        end
      end
    end
  end

  def html_attachment_govspeak_headers_html(attachment)
    tag.ol(class: ("unnumbered" if attachment.manually_numbered_headings?)) do
      html_attachment_govspeak_headers(attachment).reduce("") { |html, header|
        css_class = header_contains_manual_numbering?(header) ? "numbered" : nil
        html << tag.li(link_to(header.text, "##{header.id}"), class: css_class)
      }.html_safe
    end
  end

  def header_contains_manual_numbering?(header)
    header.text.include?('<span class="heading-number">')
  end

  def govspeak_header_hierarchy(govspeak)
    headers = []
    govspeak_headers(govspeak, 2..3).each do |header|
      case header.level
      when 2
        headers << { header:, children: [] }
      when 3
        raise Govspeak::OrphanedHeadingError, header.text if headers.none?

        headers.last[:children] << header
      end
    end
    headers
  end

  def inline_attachment_code_tags(number)
    tag.code("!@#{number}") <<
      " or ".html_safe <<
      tag.code("[InlineAttachment:#{number}]")
  end

  def fraction_image(numerator, denominator)
    denominator.downcase! if %w[X Y].include? denominator
    if numerator.present? && denominator.present? && asset_exists?("fractions/#{numerator}_#{denominator}.png")
      asset_path("fractions/#{numerator}_#{denominator}.png", host: Whitehall.public_root)
    end
  end

  def govspeak_options_for_html_attachment(attachment)
    numbering_method = attachment.manually_numbered_headings? ? :manual : :auto
    { heading_numbering: numbering_method, contact_heading_tag: "h4" }
  end

  def whitehall_admin_links(body)
    govspeak = build_govspeak_document(body)
    links = Govspeak::LinkExtractor.new(govspeak).call
    links.select { |link| DataHygiene::GovspeakLinkValidator.is_internal_admin_link?(link) }
  end

  def bare_govspeak_to_html(govspeak, images = [], options = {}, &block)
    # pre-processors
    govspeak = remove_extra_quotes_from_blockquotes(govspeak)
    govspeak = render_embedded_contacts(govspeak, options[:contact_heading_tag])
    govspeak = render_embedded_fractions(govspeak)
    govspeak = set_classes_for_charts(govspeak)
    govspeak = set_classes_for_sortable_tables(govspeak)

    markup_to_nokogiri_doc(govspeak, images, options[:allowed_elements])
      .tap { |nokogiri_doc|
        # post-processors
        replace_internal_admin_links_in(nokogiri_doc, &block)
        add_class_to_links(nokogiri_doc)
        add_class_to_last_blockquote_paragraph(nokogiri_doc)

        case options[:heading_numbering]
        when :auto
          add_heading_numbers(nokogiri_doc)
        when :manual
          add_manual_heading_numbers(nokogiri_doc)
        end
      }
      .to_html
      .html_safe
  end

private

  def asset_exists?(path)
    # This acts as environment agnostic look-up to Rails.application.assets
    # to find whether a file is in Sprockets. In a prod environment
    # Rails.application.assets is nil (and the asset manifest is used instead)
    # whereas in dev/test using the Rails.application.asset_manifest only
    # works if the developer has run assets:precompile rake task first (which
    # can be a point of frustration for devs)
    # Using the build_environment allows this to flip between either as per:
    # https://github.com/rails/sprockets-rails/issues/237#issuecomment-308666272
    Sprockets::Railtie.build_environment(Rails.application).find_asset(path)
  end

  def remove_extra_quotes_from_blockquotes(govspeak)
    Whitehall::ExtraQuoteRemover.new.remove(govspeak)
  end

  def wrapped_in_govspeak_div(html_string)
    tag.div(html_string.html_safe, class: "govspeak")
  end

  def render_embedded_contacts(govspeak, heading_tag)
    return govspeak if govspeak.blank?

    govspeak.gsub(Govspeak::EmbeddedContentPatterns::CONTACT) do
      if (contact = Contact.find_by(id: Regexp.last_match(1)))
        render(partial: "contacts/contact", locals: { contact:, heading_tag: }, formats: [:html])
      else
        ""
      end
    end
  end

  def render_embedded_fractions(govspeak)
    return govspeak if govspeak.blank?

    govspeak.gsub(GovspeakHelper::FRACTION_REGEXP) do |_match|
      if Regexp.last_match(1).present? && Regexp.last_match(2).present?
        render(partial: "shared/govspeak_fractions", formats: [:html], locals: { numerator: Regexp.last_match(1), denominator: Regexp.last_match(2) })
      else
        ""
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
      stacked = ".mc-stacked" if Regexp.last_match(1).include? "stacked"
      compact = ".compact" if Regexp.last_match(1).include? "compact"
      negative = ".mc-negative" if Regexp.last_match(1).include? "negative"

      [
        "{:",
        ".js-barchart-table",
        stacked,
        compact,
        negative,
        ".mc-auto-outdent",
        "}",
      ].join(" ")
    end
  end

  def replace_internal_admin_links_in(nokogiri_doc, &block)
    Govspeak::AdminLinkReplacer.new(nokogiri_doc).replace!(&block)
  end

  def add_class_to_last_blockquote_paragraph(nokogiri_doc)
    nokogiri_doc.css("blockquote p:last-child").map do |el|
      el[:class] = "last-child"
    end
  end

  def add_class_to_links(nokogiri_doc)
    nokogiri_doc.css("a").map do |el|
      el[:class] = "govuk-link" unless el[:class] =~ /button/
    end
  end

  def add_heading_numbers(nokogiri_doc)
    h2_depth = 0
    h3_depth = 0
    nokogiri_doc.css("h2, h3").each do |el|
      if el.name == "h2"
        h3_depth = 0
        number = "#{h2_depth += 1}."
      else
        number = "#{h2_depth}.#{h3_depth += 1}"
      end
      el.inner_html = el.document.fragment(%(<span class="number">#{number} </span>#{el.inner_html}))
    end
  end

  def add_manual_heading_numbers(nokogiri_doc)
    nokogiri_doc.css("h2, h3").each do |el|
      if (number = extract_number_from_heading(el))
        heading_without_number = el.inner_html.gsub(number, "")
        el.inner_html = el.document.fragment(%(<span class="number">#{number} </span>#{heading_without_number}))
      end
    end
  end

  def extract_number_from_heading(nokogiri_el)
    nokogiri_el.inner_text[/^\d+.?[^\s]*/]
  end

  def markup_to_nokogiri_doc(govspeak, images = [], allowed_elements = [])
    govspeak = build_govspeak_document(govspeak, images, allowed_elements)
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    doc.fragment(govspeak.to_html)
  end

  def govspeak_with_attachments_and_alt_format_information(govspeak, attachments = [], alternative_format_contact_email = nil)
    hosts = [Whitehall.admin_host, Whitehall.public_host]

    attachments = attachments.to_a.map do |a|
      {
        id: a.filename,
        title: a.title,
        url: a.url,
        filename: a.filename,
        file_size: a.file_size,
        thumbnail_html: attachment_thumbnail(a),
      }
    end
    govspeak = govspeak.gsub(/\n{0,2}^!@([0-9]+)\s*/) do
      if (attachment = attachments[Regexp.last_match(1).to_i - 1])
        attachment = "\n\n[Attachment:#{attachment[:filename]}]\n\n"
      else
        "\n\n"
      end
    end
    # return govspeak
    # hosts = [Whitehall.admin_host, Whitehall.public_host]

    govspeak = Govspeak::Document.new(govspeak, { document_domains: hosts, attachments: }).tap do |document|
      # document.images = images
    end
    return govspeak.to_html.html_safe

    govspeak.gsub(/\[InlineAttachment:([0-9]+)\]/) do
      if (attachment = attachments[Regexp.last_match(1).to_i - 1])
        render(partial: "documents/inline_attachment", formats: :html, locals: { attachment: }).chomp
      else
        ""
      end
    end
  end

  def edition_body_with_attachments_and_alt_format_information(edition)
    attachments = edition.allows_attachments? ? edition.attachments : []
    govspeak_with_attachments_and_alt_format_information(edition.body, attachments, edition.alternative_format_contact_email)
  end

  def build_govspeak_document(govspeak, images = [], allowed_elements = [])
    hosts = [Whitehall.admin_host, Whitehall.public_host]
    Govspeak::Document.new(govspeak, { document_domains: hosts, allowed_elements: }).tap do |document|
      document.images = images
    end
  end
end
