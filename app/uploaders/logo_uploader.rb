class LogoUploader < WhitehallUploader
  def extension_allowlist
    %w[jpg jpeg gif png]
  end
end
