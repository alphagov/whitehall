class ImageUploader < WhitehallUploader
  include CarrierWave::MiniMagick

  process :store_dimensions

  configure do |config|
    config.remove_previously_stored_files_after_update = false
    config.storage = Storage::PreviewableStorage
    config.validate_integrity = true
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

  def downloader
    WhitehallDownloader
  end

  def extension_allowlist
    %w[jpg jpeg gif png svg]
  end

  def store_dimensions
    if file && bitmap?(file) && model
      begin
        image = ::MiniMagick::Image.open(file.file)
        model.width, model.height = image.dimensions
      rescue MiniMagick::Error, MiniMagick::Invalid
        logger.warn("Error opening #{file.file}")
      end
    end
  end

  Whitehall.image_kinds.each do |image_kind, image_kind_config|
    use_versions_for_this_image_kind_proc = lambda do |uploader, opts|
      uploader.model.image_kind == image_kind && uploader.bitmap?(opts[:file]) && !uploader.model.requires_crop?
    end

    image_kind_config.versions.each do |v|
      def crop_to_crop_data(from_version)
        manipulate! do |_img|
          img = MiniMagick::Image.open(url)

          # prevents running crop on variants
          # based on an already cropped variant
          if model.crop_data_to_params.present? && from_version.blank?
            img.crop(model.crop_data_to_params)
          end

          img
        end
      end

      version v.name, from_version: v.from_version&.to_sym, if: use_versions_for_this_image_kind_proc do
        def crop_image?(_image)
          !model.requires_crop?
        end

        process crop_to_crop_data: [v.from_version], if: :crop_image?
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

  private

  def check_dimensions!(new_file)
    super
  rescue CarrierWave::IntegrityError
    raise CarrierWave::IntegrityError, "is too small. Select an image that is at least #{width_range.begin} pixels wide and at least #{height_range.begin} pixels tall"
  end  
end
