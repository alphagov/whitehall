class LogoUploader < WhitehallUploader
  storage :asset_manager_and_file_system

  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
