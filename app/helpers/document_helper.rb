module DocumentHelper
  include ApplicationHelper
  include InlineSvg::ActionView::Helpers

  MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document".freeze
  MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet".freeze
  MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation".freeze

  def document_block_counter
    # rubocop:disable Rails/HelperInstanceVariable
    @block_count ||= 0
    @block_count += 1
    # rubocop:enable Rails/HelperInstanceVariable
  end

  def published_or_updated(edition)
    edition.first_published_version? ? t("document.published") : t("document.updated")
  end

  def file_abbr_tag(abbr, title)
    tag.abbr(abbr, title:)
  end

  def humanized_content_type(file_extension)
    file_extension_vs_humanized_content_type = {
      "chm" => file_abbr_tag("CHM", "Microsoft Compiled HTML Help"),
      "csv" => file_abbr_tag("CSV", "Comma-separated Values"),
      "diff" => file_abbr_tag("DIFF", "Plain text differences"),
      "doc" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
      "docx" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
      "dot" => file_abbr_tag("DOT", "MS Word Document Template"),
      "dxf" => file_abbr_tag("DXF", "AutoCAD Drawing Exchange Format"),
      "eps" => file_abbr_tag("EPS", "Encapsulated PostScript"),
      "gif" => file_abbr_tag("GIF", "Graphics Interchange Format"),
      "gml" => file_abbr_tag("GML", "Geography Markup Language"),
      "html" => file_abbr_tag("HTML", "Hypertext Markup Language"),
      "ics" => file_abbr_tag("ICS", "iCalendar file"),
      "jpg" => "JPEG",
      "odp" => file_abbr_tag("ODP", "OpenDocument Presentation"),
      "ods" => file_abbr_tag("ODS", "OpenDocument Spreadsheet"),
      "odt" => file_abbr_tag("ODT", "OpenDocument Text document"),
      "pdf" => file_abbr_tag("PDF", "Portable Document Format"),
      "png" => file_abbr_tag("PNG", "Portable Network Graphic"),
      "ppt" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
      "pptx" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
      "ps" => file_abbr_tag("PS", "PostScript"),
      "rdf" => file_abbr_tag("RDF", "Resource Description Framework"),
      "rtf" => file_abbr_tag("RTF", "Rich Text Format"),
      "sch" => file_abbr_tag("SCH", "XML based Schematic"),
      "txt" => "Plain text",
      "vcf" => "vCard file",
      "wsdl" => file_abbr_tag("WSDL", "Web Services Description Language"),
      "xls" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
      "xlsm" => file_abbr_tag("XLSM", "MS Excel Macro-Enabled Workbook"),
      "xlsx" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
      "xlt" => file_abbr_tag("XLT", "MS Excel Spreadsheet Template"),
      "xml" => file_abbr_tag("XML", "XML document"),
      "xsd" => file_abbr_tag("XSD", "XML Schema"),
      "xslt" => file_abbr_tag("XSLT", "Extensible Stylesheet Language Transformation"),
      "zip" => file_abbr_tag("ZIP", "Zip archive"),
    }
    file_extension_vs_humanized_content_type[file_extension.downcase] if file_extension.present?
  end

  def attachment_reference(attachment)
    ref = []
    ref << "ISBN #{tag.span(attachment.isbn, class: 'isbn')}" if attachment.isbn.present?
    ref << tag.span(attachment.unique_reference, class: "unique_reference") if attachment.unique_reference.present?
    if attachment.command_paper_number.present?
      ref << tag.span(attachment.command_paper_number, class: "command_paper_number")
    end
    if attachment.hoc_paper_number.present?
      paper_number = tag.span("HC #{attachment.hoc_paper_number}", class: "house_of_commons_paper_number")
      parliamentary_session = tag.span(attachment.parliamentary_session, class: "parliamentary_session")
      ref << "#{paper_number} #{parliamentary_session}"
    end

    ref.join(", ").html_safe
  end

  def attachment_thumbnail(attachment)
    if attachment.pdf?
      image_tag(attachment.file.thumbnail.url, alt: "")
    elsif attachment.html?
      inline_svg_tag("attachment-icons/html.svg", aria_hidden: true)
    elsif %w[doc docx odt].include? attachment.file_extension
      inline_svg_tag("attachment-icons/document.svg", aria_hidden: true)
    elsif %w[xls xlsx ods csv].include? attachment.file_extension.downcase
      inline_svg_tag("attachment-icons/spreadsheet.svg", aria_hidden: true)
    else
      inline_svg_tag("attachment-icons/generic.svg", aria_hidden: true)
    end
  end

  def alternative_format_order_link(attachment, alternative_format_contact_email)
    attachment_info = []
    attachment_info << "  Title: #{attachment.title}"
    attachment_info << "  Original format: #{attachment.file_extension}"
    attachment_info << "  ISBN: #{attachment.isbn}" if attachment.isbn.present?
    attachment_info << "  Unique reference: #{attachment.unique_reference}" if attachment.unique_reference.present?
    attachment_info << "  Command paper number: #{attachment.command_paper_number}" if attachment.command_paper_number.present?
    if attachment.hoc_paper_number.present?
      attachment_info << "  House of Commons paper number: #{attachment.hoc_paper_number}"
      attachment_info << "  Parliamentary session: #{attachment.parliamentary_session}"
    end

    mail_to alternative_format_contact_email,
            alternative_format_contact_email,
            subject: "Request for '#{attachment.title}' in an alternative format",
            body: %(Details of document required:

#{attachment_info.join("\n")}

Please tell us:

  1. What makes this format unsuitable for you?
  2. What format you would prefer?
      )
  end

  def attachment_references(attachment)
    references = []
    references << "ISBN: #{attachment.isbn}" if attachment.isbn.present?
    references << "Unique reference: #{attachment.unique_reference}" if attachment.unique_reference.present?
    references << "Command paper number: #{attachment.command_paper_number}" if attachment.command_paper_number.present?
    references << "HC: #{attachment.hoc_paper_number} #{attachment.parliamentary_session}" if attachment.hoc_paper_number.present?
    prefix = references.size == 1 ? "and its reference" : "and its references"
    references.any? ? ", #{prefix} (#{references.join(', ')})" : ""
  end

  def attachment_attributes(attachment)
    attributes = []
    if attachment.html?
      attributes << tag.span("HTML", class: "type")
    elsif attachment.external?
      attributes << tag.span(attachment.url, class: "url")
    else
      attributes << tag.span(humanized_content_type(attachment.file_extension), class: "type")
      attributes << tag.span(number_to_human_size(attachment.file_size), class: "file-size")
      attributes << tag.span(pluralize(attachment.number_of_pages, "page"), class: "page-length", lang: "en") if attachment.number_of_pages.present?
    end
    attributes.join(", ").html_safe
  end

  def native_language_name_for(locale)
    Locale.new(locale).native_language_name
  end

  def link_to_translation(locale)
    options = {}

    options[:locale] = locale
    options[:locale] = nil if locale.to_s == "en"

    link_to native_language_name_for(locale), options, lang: locale, class: "govuk-link"
  end

  def render_timeline(timeline)
    list_items = timeline.entries.map do |entry|
      case entry
      when EditorialRemark
        render partial: "admin/editions/remark_entry", locals: { remark: entry }
      when Document::PaginatedHistory::AuditTrailEntry
        render partial: "admin/editions/audit_trail_entry", locals: { audit_trail_entry: entry }
      end
    end

    tag.ul(class: "list-unstyled") do
      list_items.join.html_safe
    end
  end
end
