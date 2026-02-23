class ImageUploader < WhitehallUploader
  class_attribute :setting

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

  def crop_to_crop_data(version)
    manipulate! do |img|
      # prevents running crop on variants
      # based on an already cropped variant
      if model.crop_data_to_params(version.width, version.height).present? && version.from_version.blank?
        img.crop(model.crop_data_to_params(version.width, version.height))
      end

      img
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
