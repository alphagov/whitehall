class ResponseDocumentUploader < WhitehallUploader
  storage Storage::PreviewableStorage
  def extension_allowlist
    %w[pdf csv rtf doc docx xls xlsx odt ods]
  end

  delegate :asset_manager_path, to: :file
end
