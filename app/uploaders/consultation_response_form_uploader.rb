# encoding: utf-8

class ConsultationResponseFormUploader < WhitehallUploader
  storage :asset_manager_and_quarantined_file_storage

  def extension_whitelist
    %w(pdf csv rtf doc docx xls xlsx odt ods)
  end
end
