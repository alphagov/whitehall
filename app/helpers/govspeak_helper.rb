require "delegate"

module GovspeakHelper
  include Rails.application.routes.url_helpers
  include AttachmentsHelper

  def govspeak_to_html(govspeak, options = {})
    wrapped_in_govspeak_div(bare_govspeak_to_html(govspeak, [], [], options))
  end

  def govspeak_edition_to_html(edition)
    return "" unless edition

    wrapped_in_govspeak_div(bare_govspeak_edition_to_html(edition))
  end

  def govspeak_with_attachments_to_html(body, attachments = [], alternative_format_contact_email = nil)
    attachments = prepare_attachments(attachments, alternative_format_contact_email)
    wrapped_in_govspeak_div(bare_govspeak_to_html(body, [], attachments))
  end

  def govspeak_to_html_with_images_and_attachments(govspeak, images = [], attachments = [], alternative_format_contact_email = nil)
    mapped_images = prepare_images(images)
    mapped_attachments = prepare_attachments(attachments, alternative_format_contact_email)

    wrapped_in_govspeak_div(bare_govspeak_to_html(govspeak, mapped_images, mapped_attachments))
  end

  def bare_govspeak_edition_to_html(edition)
    images = prepare_images(edition.try(:images) || [])

    # some Edition types don't allow attachments to be embedded in body content
    attachments = if edition.allows_inline_attachments?
                    prepare_attachments(edition.attachments, edition.alternative_format_contact_email)
                  else
                    []
                  end

    bare_govspeak_to_html(edition.body, images, attachments)
  end

  def govspeak_html_attachment_to_html(html_attachment)
    # HTML attachments can embed images - but not attachments - from their parent Edition
    images = prepare_images(html_attachment.attachable.try(:images) || [])
    locale = html_attachment.translated_locales.first

    heading_numbering = html_attachment.manually_numbered_headings? ? :manual : :auto
    options = { heading_numbering:, locale:, contact_heading_tag: "h4" }

    wrapped_in_govspeak_div(bare_govspeak_to_html(html_attachment.body, images, [], options))
  end

  def prepare_images(images)
    images
      .select { |image| image.image_data&.image_kind_config&.permits? "govspeak_embed" }
      .select { |image| image.image_data&.all_asset_variants_uploaded? }
      .map do |image|
      {
        id: image.filename,
        image_data_id: image.image_data_id,
        edition_id: image.edition_id,
        alt_text: image.alt_text,
        url: image.url,
        caption: image.caption,
        created_at: image.created_at,
        updated_at: image.updated_at,
      }
    end
  end

  def prepare_attachments(attachments, alternative_format_contact_email)
    attachments
      .select { |attachment| !attachment.file? || attachment.attachment_data&.all_asset_variants_uploaded? }
      .map do |attachment|
      attachment_component_params(attachment, alternative_format_contact_email:)
    end
  end

  def govspeak_headers(govspeak, level = (2..2))
    build_govspeak_document(govspeak).headers.select do |header|
      level.cover?(header.level)
    end
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

  def bare_govspeak_to_html(govspeak, images = [], attachments = [], options = {}, &block)
    # pre-processors
    govspeak = convert_attachment_syntax(govspeak, attachments)
    govspeak = render_embedded_contacts(govspeak, options[:contact_heading_tag])

    locale = options[:locale]

    markup_to_nokogiri_doc(govspeak, images, attachments, locale:)
      .tap { |nokogiri_doc|
        # post-processors
        replace_internal_admin_links_in(nokogiri_doc, &block)
        add_class_to_links(nokogiri_doc)

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

  def replace_internal_admin_links_in(nokogiri_doc, &block)
    Govspeak::AdminLinkReplacer.new(nokogiri_doc).replace!(&block)
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

  def markup_to_nokogiri_doc(govspeak, images = [], attachments = [], options = {})
    govspeak = build_govspeak_document(govspeak, images, attachments, options)
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    doc.fragment(govspeak.to_html)
  end

  # convert deprecated Whitehall !@n syntax to Govspeak [Attachment: example.pdf] syntax
  def convert_attachment_syntax(govspeak, attachments = [])
    return govspeak if govspeak.blank?

    govspeak = govspeak.gsub(/\n{0,2}^!@([0-9]+)\s*/) do
      if (attachment = attachments[Regexp.last_match(1).to_i - 1])
        "\n\n[Attachment: #{attachment[:id]}]\n\n"
      else
        "\n\n"
      end
    end

    govspeak.gsub(/\[InlineAttachment:([0-9]+)\]/) do
      if (attachment = attachments[Regexp.last_match(1).to_i - 1])
        "[AttachmentLink: #{attachment[:id]}]"
      else
        ""
      end
    end
  end

  def build_govspeak_document(govspeak, images = [], attachments = [], options = {})
    locale = options[:locale]

    Govspeak::Document.new(
      govspeak,
      images:,
      attachments:,
      document_domains: [Whitehall.admin_host, Whitehall.public_host],
      locale:,
    )
  end
end
