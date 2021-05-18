class ConsultationResponseFormUploader < WhitehallUploader
  def extension_allowlist
    %w[pdf csv rtf doc docx xls xlsx odt ods]
  end
end
