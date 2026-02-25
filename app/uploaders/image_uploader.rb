class ImageUploader < WhitehallUploader
  include CarrierWave::MiniMagick

  configure do |config|
    config.remove_previously_stored_files_after_update = false
    config.storage = Storage::PreviewableStorage
    config.validate_integrity = true
  end

  def downloader
    # this overloads the downloader from Carrierwave::Uploader::Base
    # so that `download!` can be used in development and test environments
    WhitehallDownloader
  end

  def extension_allowlist
    %w[jpg jpeg gif png svg].freeze
  end

  Whitehall.image_kinds.each do |image_kind, image_kind_config|
    use_versions_for_this_image_kind_proc = lambda do |uploader, opts|
      uploader.model.image_kind == image_kind && uploader.bitmap?(opts[:file]) && !uploader.model.requires_crop?
    end

    image_kind_config.versions.each do |v|
      version v.name, from_version: v.from_version&.to_sym, version: v, if: use_versions_for_this_image_kind_proc do
        def image_kind_version
          self.class.version_options[:version]
        end

        def from_version
          self.class.version_options[:from_version]
        end

        delegate :crop, to: :model

        def crop_image?(_image)
          !model.requires_crop?
        end

        def crop_to_crop_data
          manipulate! do |img|
            # prevents running crop on variants
            # based on an already cropped variant
            if crop_data_to_params
              img.crop(crop_data_to_params)
            end

            img
          end
        end

        def crop_data_to_params
          return unless crop.present? && from_version.blank?

          "#{image_kind_version.width * crop.scale}x#{image_kind_version.height * crop.scale}+#{crop.relative_x_to_width(image_kind_version.width)}+#{crop.relative_y_to_height(image_kind_version.height)}"
        end

        process :crop_to_crop_data, if: :crop_image?
        process resize_to_fill: v.resize_to_fill
      end
    end
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

private

  def check_dimensions!(new_file)
    super
  rescue ImageKind::MissingKindError
    raise CarrierWave::IntegrityError, "does not have a selected image kind. Select an image kind for the image"
  rescue MiniMagick::Error
    raise CarrierWave::IntegrityError, "could not be read. The file may not be an image or may be corrupt"
  rescue CarrierWave::IntegrityError
    raise CarrierWave::IntegrityError, "is too small. Select an image that is at least #{width_range.begin} pixels wide and at least #{height_range.begin} pixels tall"
  end
end
