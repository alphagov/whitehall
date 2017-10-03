# encoding: utf-8

class ConsultationResponseFormUploader < WhitehallUploader
  storage :asset_manager_and_file_system

  def extension_whitelist
    %w(pdf csv rtf doc docx xls xlsx odt ods)
  end
end
