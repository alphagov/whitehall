require "delegate"

module GovspeakHelper
  include Rails.application.routes.url_helpers
  include AttachmentsHelper

  def govspeak_to_html(govspeak, options = {})
    bare_govspeak_to_html(govspeak, [], [], options)
  end

  def govspeak_edition_to_html(edition)
    return "" unless edition

    bare_govspeak_edition_to_html(edition)
  end

  def govspeak_with_attachments_to_html(body, attachments = [], alternative_format_contact_email = nil)
    attachments = prepare_attachments(attachments, alternative_format_contact_email)
    bare_govspeak_to_html(body, [], attachments)
  end

  def govspeak_to_html_with_images_and_attachments(govspeak, images = [], attachments = [], alternative_format_contact_email = nil)
    mapped_images = prepare_images(images)
    mapped_attachments = prepare_attachments(attachments, alternative_format_contact_email)

    bare_govspeak_to_html(govspeak, mapped_images, mapped_attachments)
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

    bare_govspeak_to_html(html_attachment.body, images, [], options)
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

  def bare_govspeak_to_html(govspeak = "", images = [], attachments = [], options = {}, &block)
    # pre-processors
    govspeak = convert_attachment_syntax(govspeak, attachments)
    govspeak = render_embedded_contacts(govspeak, options[:contact_heading_tag])
    govspeak = add_heading_numbers(govspeak) if options[:heading_numbering] == :auto
    govspeak = add_manual_heading_numbers(govspeak) if options[:heading_numbering] == :manual

    locale = options[:locale]

    html = markup_to_nokogiri_doc(govspeak, images, attachments, locale:)
      .tap { |nokogiri_doc|
        # post-processors
        replace_internal_admin_links_in(nokogiri_doc, &block)
      }
      .to_html

    "<div class=\"govspeak\">#{html}</div>".html_safe
  end

  def govspeak_to_admin_html(govspeak, images = [], attachments = [], alternative_format_contact_email = nil)
    images = prepare_images(images)
    attachments = prepare_attachments(attachments, alternative_format_contact_email)
    govspeak = ContentBlockManager::FindAndReplaceEmbedCodesService.call(govspeak || "")
    bare_govspeak_to_admin_html(govspeak, images, attachments)
  end

  def govspeak_edition_to_admin_html(edition)
    images = prepare_images(edition.try(:images) || [])

    # some Edition types don't allow attachments to be embedded in body content
    attachments = if edition.allows_inline_attachments?
                    prepare_attachments(edition.attachments, edition.alternative_format_contact_email)
                  else
                    []
                  end

    bare_govspeak_to_admin_html(edition.body, images, attachments)
  end

  def bare_govspeak_to_admin_html(govspeak, images = [], attachments = [])
    bare_govspeak_to_html(govspeak, images, attachments) do |replacement_html, edition|
      latest_edition = edition && edition.document.latest_edition
      if latest_edition.nil?
        replacement_html = tag.del(replacement_html)
        explanation = state = "deleted"
      else
        state = latest_edition.state
        explanation = link_to(state, admin_edition_path(latest_edition))
      end

      tag.span class: "#{state}_link" do
        annotation = tag.sup(safe_join(["(", explanation, ")"]), class: "explanation")
        safe_join [replacement_html, annotation], " "
      end
    end
  end

private

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

  def add_heading_numbers(govspeak)
    return govspeak if govspeak.blank?

    h2 = 0
    h3 = 0

    govspeak.gsub(/^(###|##)\s*(.+)$/) do
      hashes = Regexp.last_match(1)
      heading_text = Regexp.last_match(2).strip

      if hashes == "##"
        h2 += 1
        h3 = 0
        num = "#{h2}."
      else # "###"
        h2 = 1 if h2.zero?
        h3 += 1
        num = "#{h2}.#{h3}"
      end

      # We have to manually derive and append a slug otherwise when Govspeak
      # generates the HTML, it includes the <span> and number in the ID. Hence
      # the `heading_text.parameterize`
      "#{hashes} <span class=\"number\">#{num} </span>#{heading_text} {##{heading_text.parameterize}}"
    end
  end

  def add_manual_heading_numbers(govspeak)
    return govspeak if govspeak.blank?

    govspeak.gsub(/^(###|##)\s*(\S+)\s+(.*)$/) do
      match_data = Regexp.last_match
      hashes = match_data[1]
      token = match_data[2]
      title = match_data[3].strip

      # Only treat as manual if token is purely numeric (1. / 2) / 42.12 / 3.0.1)
      if token.match?(/\A\d+(?:\.\d+)*(?:[.)])?\z/) && !title.empty?
        display = token.end_with?(")") ? token.sub(/\)\z/, ".") : token
        slug    = title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
        "#{hashes} <span class=\"number\">#{display} </span> #{title} {##{slug}}"
      else
        match_data[0] # keep the original heading exactly as written
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
