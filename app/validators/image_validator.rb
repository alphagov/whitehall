module ImageValidator
  EXTENSION_ALLOWLIST = %w[jpg jpeg gif png].freeze

  def extension_allowlist
    EXTENSION_ALLOWLIST
  end

  def height_range
    return unless bitmap?(file)

    if model.respond_to?(:image_kind_config)
      model.image_kind_config.valid_height..
    else
      0..
    end
  end

  def width_range
    return unless bitmap?(file)

    if model.respond_to?(:image_kind_config)
      model.image_kind_config.valid_width..
    else
      0..
    end
  end
end
