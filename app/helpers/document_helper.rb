module DocumentHelper
  include ApplicationHelper
  include InlineSvg::ActionView::Helpers

  MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document".freeze
  MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet".freeze
  MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation".freeze

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

private

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
end
