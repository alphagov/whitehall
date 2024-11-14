class ImageUploader < WhitehallUploader
  include CarrierWave::MiniMagick

  configure do |config|
    config.remove_previously_stored_files_after_update = false
    config.storage = Storage::PreviewableStorage
  end

  def extension_allowlist
    %w[jpg jpeg gif png svg]
  end

  version :s960, if: :bitmap? do
    process resize_to_fill: [960, 640]
  end
  version :s712, from_version: :s960, if: :bitmap? do
    process resize_to_fill: [712, 480]
  end
  version :s630, from_version: :s960, if: :bitmap? do
    process resize_to_fill: [630, 420]
  end
  version :s465, from_version: :s960, if: :bitmap? do
    process resize_to_fill: [465, 310]
  end
  version :s300, from_version: :s960, if: :bitmap? do
    process resize_to_fill: [300, 195]
  end
  version :s216, from_version: :s960, if: :bitmap? do
    process resize_to_fill: [216, 140]
  end

  def bitmap?(new_file)
    return if new_file.nil?

    new_file.content_type !~ /svg/
  end

  def image_cache
    if send("cache_id").present?
      file.file.gsub("/govuk/whitehall/carrierwave-tmp/", "")
    end
  end

  def active_version_names
    # active_versions is protected, so it can only be called by subclasses
    # it returns an array of [key, value] pairs, and we want the keys
    active_versions.map(&:first)
  end
end
