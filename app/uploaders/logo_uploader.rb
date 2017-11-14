class LogoUploader < WhitehallUploader
  storage :asset_manager

  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
