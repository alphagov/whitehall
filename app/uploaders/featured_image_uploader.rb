class FeaturedImageUploader < ImageUploader
  def extension_allowlist
    %w[jpg jpeg gif png].freeze
  end

  def height_range
    return unless bitmap?(file)

    if model.respond_to?(:image_kind_config)
      model.image_kind_config.valid_height..model.image_kind_config.valid_height
    end
  end

  def width_range
    return unless bitmap?(file)

    if model.respond_to?(:image_kind_config)
      model.image_kind_config.valid_width..model.image_kind_config.valid_width
    end
  end

  def check_dimensions!(new_file)
    super
  rescue MiniMagick::Error
    raise CarrierWave::IntegrityError, "could not be read. The file may not be an image or may be corrupt."
  rescue CarrierWave::IntegrityError => e
    raise CarrierWave::IntegrityError, "could not be read. The file may not be an image or may be corrupt." if e.message.match("file may not be an image or may be corrupt")

    if width_range&.begin && width < width_range.begin || height_range&.begin && height < height_range.begin
      raise CarrierWave::IntegrityError, "is too small. Select an image that is #{model.image_kind_config.valid_width} pixels wide and #{model.image_kind_config.valid_height} pixels tall."
    elsif width_range&.end && width > width_range.end || height_range&.end && height > height_range.end
      raise CarrierWave::IntegrityError, "is too large. Select an image that is #{model.image_kind_config.valid_width} pixels wide and #{model.image_kind_config.valid_height} pixels tall."
    end
  end
end
