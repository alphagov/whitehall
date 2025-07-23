class AttachmentUploader < WhitehallUploader
  PDF_CONTENT_TYPE = "application/pdf".freeze
  INDEXABLE_TYPES = %w[csv doc docx ods odp odt pdf ppt pptx rdf rtf txt xls xlsx xml].freeze
  EXTENSION_ALLOW_LIST = %w[chm csv diff doc docx dot dxf eps gif gml ics jpg kml odp ods odt pdf png ppt pptx ps rdf ris rtf sch txt vcf wsdl xls xlsm xlsx xlt xml xsd xslt].freeze
  MIME_ALLOW_LIST = EXTENSION_ALLOW_LIST.flat_map { |ext| MIME::Types.type_for(ext).map(&:to_s) }

  storage Storage::AttachmentStorage

  process :set_content_type
  def set_content_type
    filename = full_filename(file.file)
    types = MIME::Types.type_for(filename)
    content_type = types.first.content_type if types.any?
    content_type = "text/xml" if filename.end_with?(".xsd")
    content_type = "text/csv" if content_type == "text/comma-separated-values"
    content_type = "application/pdf" if content_type == "application/octet-stream"
    file.content_type = content_type
  end

  def pdf?(file)
    file.content_type == PDF_CONTENT_TYPE
  end

  def extension_allowlist
    EXTENSION_ALLOW_LIST
  end
end
