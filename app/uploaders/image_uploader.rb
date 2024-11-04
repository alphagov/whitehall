class ImageUploader < WhitehallUploader
  include CarrierWave::MiniMagick

  configure do |config|
    config.remove_previously_stored_files_after_update = false
    config.storage = Storage::PreviewableStorage
  end

  def extension_allowlist
    %w[jpg jpeg gif png svg]
  end

  Whitehall.image_kinds.each do |image_kind, image_kind_config|
    use_versions_for_this_image_kind_proc = lambda do |uploader, opts|
      uploader.model.image_kind == image_kind && uploader.bitmap?(opts[:file])
    end

    image_kind_config.versions.each do |v|
      version v.name, from_version: v.from_version&.to_sym, if: use_versions_for_this_image_kind_proc do
        process resize_to_fill: v.resize_to_fill
      end
    end
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
