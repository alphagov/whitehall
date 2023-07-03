class FeaturedImageUploader < WhitehallUploader
  include CarrierWave::MiniMagick

  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  configure do |config|
    config.remove_previously_stored_files_after_update = false
    config.validate_integrity = true
  end

  version(:s960) { process resize_to_fill: [960, 640] }
  version(:s712, from_version: :s960) { process resize_to_fill: [712, 480] }
  version(:s630, from_version: :s960) { process resize_to_fill: [630, 420] }
  version(:s465, from_version: :s960) { process resize_to_fill: [465, 310] }
  version(:s300, from_version: :s960) { process resize_to_fill: [300, 195] }
  version(:s216, from_version: :s960) { process resize_to_fill: [216, 140] }

  def image_cache
    file.file.gsub("/govuk/whitehall/carrierwave-tmp/", "") if send("cache_id").present?
  end
end
