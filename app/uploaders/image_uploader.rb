class ImageUploader < WhitehallUploader
  include CarrierWave::MiniMagick
  include ImageVersions::DefaultImageVersions

  configure do |config|
    config.remove_previously_stored_files_after_update = false
    config.storage = Storage::PreviewableStorage
  end

  def extension_allowlist
    %w[jpg jpeg gif png svg]
  end


  def image_cache
    if send("cache_id").present?
      file.file.gsub("/govuk/whitehall/carrierwave-tmp/", "")
    end
  end
end
