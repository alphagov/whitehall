require "delegate"

module GovspeakHelper
  include Rails.application.routes.url_helpers

  def govspeak_to_html(govspeak, options = {})
    images = prepare_images(options[:images] || [])
    attachments = prepare_attachments(options[:attachments] || [])

    processed_govspeak = preprocess_govspeak(govspeak, attachments, options)
    html = markup_to_nokogiri_doc(processed_govspeak, images, attachments, locale: options[:locale], auto_numbered_headers: options[:auto_numbered_headers])
      .to_html

    "<div class=\"govspeak\">#{html}</div>".html_safe
  end

  def govspeak_edition_to_html(edition, options = {})
    return "" unless edition

    options.merge!(images: edition.try(:images))
    # some Edition types don't allow attachments to be embedded in body content
    if edition.allows_inline_attachments?
      options.merge!(
        attachments: edition.attachments,
        alternative_format_contact_email: edition.alternative_format_contact_email,
      )
    end

    govspeak_to_html(edition.body, options)
  end

  def govspeak_html_attachment_to_html(html_attachment)
    # HTML attachments can embed images - but not attachments - from their parent Edition
    images = html_attachment.attachable.try(:images)
    locale = html_attachment.translated_locales.first

    options = { locale:, contact_heading_tag: "h4" }
    options.merge!(auto_numbered_headers: true) unless html_attachment.manually_numbered_headings?

    govspeak_to_html(html_attachment.body, options.merge(images: images))
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
        url: image.embed_url,
        caption: image.caption,
        created_at: image.created_at,
        updated_at: image.updated_at,
      }
    end
  end

  def prepare_attachments(attachments)
    attachments
      .select { |attachment| !attachment.file? || attachment.attachment_data&.all_asset_variants_uploaded? }
      .map(&:publishing_component_params)
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

  def preprocess_govspeak(govspeak, attachments, options)
    govspeak ||= ""
    govspeak = ContentBlock::FindAndReplaceEmbedCodesService.call(govspeak) if options[:preview]
    govspeak = convert_attachment_syntax(govspeak, attachments)
    govspeak = render_embedded_contacts(govspeak, options[:contact_heading_tag])
    govspeak = sanitize_custom_ids(govspeak)
    replace_internal_admin_links(govspeak, options[:preview] == true)
  end

private

  def render_embedded_contacts(govspeak, heading_tag)
    govspeak.gsub(Govspeak::EmbeddedContentPatterns::CONTACT) do
      if (contact = Contact.find_by(id: Regexp.last_match(1)))
        ApplicationController.renderer.render(template: "contacts/_contact", locals: { contact:, heading_tag: }, formats: [:html])
      else
        ""
      end
    end
  end

  def sanitize_custom_ids(govspeak)
    govspeak.gsub(/{#\d+-?([^}]*)}/) do
      "{\##{Regexp.last_match(1)}}"
    end
  end

  def replace_internal_admin_links(govspeak, preview)
    # [text](url) — skip images via negative lookbehind for "!"
    govspeak.gsub(/(?<!!)\[([^\]]+)\]\(([^)\s]+)\)/) do
      text = Regexp.last_match(1)
      href = Regexp.last_match(2)
      if InternalPathLinksValidator.is_internal_admin_link?(href)
        edition = Whitehall::AdminLinkLookup.find_edition(href)
        public_url = "[#{text}](#{edition&.public_url})"
        latest_edition = edition&.document&.latest_edition
        if preview
          if !latest_edition
            "<del>#{text}</del>"
          elsif edition == latest_edition && edition.state == "published"
            public_url
          else
            "[#{latest_edition.state}](#{admin_publication_path(latest_edition)})"
          end
        elsif edition&.linkable?
          public_url
        else
          text
        end
      else
        Regexp.last_match(0)
      end
    end
  end

  def markup_to_nokogiri_doc(govspeak, images = [], attachments = [], options = {})
    govspeak = build_govspeak_document(govspeak, images, attachments, options)
    doc = Nokogiri::HTML::Document.new
    doc.encoding = "UTF-8"
    doc.fragment(govspeak.to_html)
  end

  # convert deprecated Whitehall !@n syntax to Govspeak [Attachment: example.pdf] syntax
  def convert_attachment_syntax(govspeak, attachments = [])
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
    auto_numbered_headers = options[:auto_numbered_headers]

    Govspeak::Document.new(
      govspeak,
      images:,
      attachments:,
      document_domains: [Whitehall.admin_host, Whitehall.public_host],
      locale:,
      auto_numbered_headers:,
      auto_numbered_header_levels: [2, 3],
    )
  end
end
