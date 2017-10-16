class LogoUploader < WhitehallUploader
  storage :asset_manager_and_quarantined_file_storage

  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
