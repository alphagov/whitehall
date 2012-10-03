class ImageUploader < WhitehallUploader
  def extension_white_list
    %w(jpg jpeg gif png)
  end
end