class LogoUploader < WhitehallUploader
  def extension_whitelist
    %w(jpg jpeg gif png)
  end
end
