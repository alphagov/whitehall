class ImageUploader < WhitehallUploader
  include CarrierWave::MiniMagick

  process :store_dimensions

  crop_data_blank = lambda do | uploader, opts |
    return uploader.model.crop_data.blank?
  end

  version :cropped, unless: crop_data_blank do 
    process :crop_to_crop_data
  end

  def crop_to_crop_data
    crop_data = model.crop_data ? JSON.parse(model.crop_data) : nil

    manipulate! do |img|
      img = MiniMagick::Image.open(url)
      if crop_data
        img.crop("#{crop_data["width"]}x#{crop_data["height"]}+#{crop_data["x"]}+#{crop_data["y"]}")
      end
      img
    end
  end

  configure do |config|
    config.remove_previously_stored_files_after_update = false
    config.storage = Storage::PreviewableStorage
  end

  def extension_allowlist
    %w[jpg jpeg gif png svg]
  end

  def store_dimensions
    if file && model
      ::MiniMagick::Image.open(file.file)[:dimensions]
      model.dimensions ||= {}
      model.dimensions[:width], model.dimensions[:height] = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
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
