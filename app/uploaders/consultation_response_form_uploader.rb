# encoding: utf-8

class ConsultationResponseFormUploader < WhitehallUploader
  def extension_white_list
    %w(pdf csv rtf doc docx xls xlsx odt ods)
  end
end
