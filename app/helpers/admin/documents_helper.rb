module Admin::DocumentsHelper
  def nested_attribute_destroy_checkbox_options(form)
    checked_value, unchecked_value = '0', '1'
    checked = form.object[:_destroy].present? ? (form.object[:_destroy] == checked_value) : form.object.persisted?
    [{ checked: checked }, checked_value, unchecked_value]
  end

  def admin_documents_header_link
    admin_header_link "Documents", admin_documents_path, /^#{Whitehall.router_prefix}\/admin\/(documents|publications|policies|news_articles|consultations|speeches)/
  end

  def link_to_filter(link, options)
    link_to link, url_for(params.slice('filter', 'author', 'organisation').merge(options)), class: filter_class(options)
  end

  def filter_class(options)
    current = options.keys.all? do |key|
      options[key].to_param == params[key].to_param
    end

    'current' if current
  end


  MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document"
  MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet"
  MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation"

  FILE_EXTENSION_VS_HUMANIZED_CONTENT_TYPE = {
    "pdf" => "PDF Document",
    "csv" => "CSV Document",
    "rtf" => "RTF Document",
    "png" => "PNG Image",
    "jpg" => "JPEG Document",
    "doc" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
    "docx" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
    "xls" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
    "xlsx" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
    "ppt" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
    "pptx" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE
  }

  def humanized_content_type(file_extension)
    FILE_EXTENSION_VS_HUMANIZED_CONTENT_TYPE[file_extension.downcase] if file_extension.present?
  end

  def order_link(document)
    return "" unless document.order_url.present?
    link_to document.order_url, document.order_url, class: "order_url"
  end
end