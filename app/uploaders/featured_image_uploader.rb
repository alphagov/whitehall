class FeaturedImageUploader < WhitehallUploader
  include CarrierWave::MiniMagick

  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  configure do |config|
    # This config disables the default carrierwave behaviour of deleting previous images on update.
    # The issue with removing previous images is that the documents using them may have associations that also use the images.
    # Therefore, when the images get deleted from asset-manager, the associated published documents will 404 for the image, unless
    # an intentional update is run to inform the association that a new image has been provided.
    # Such an example is Speech document and the related Person who made the speech. Speech page shows the image of the person.
    # When Person updates the picture, Speech needs to be republished as well, otherwise it will try to show the old image (404 if deletion enabled).
    config.remove_previously_stored_files_after_update = false
    config.validate_integrity = true
  end

  Whitehall.image_kinds.fetch("default").versions.each do |v|
    version v.name, from_version: v.from_version&.to_sym do
      process resize_to_fill: v.resize_to_fill
    end
  end

  def image_cache
    file.file.gsub("/govuk/whitehall/carrierwave-tmp/", "") if send("cache_id").present?
  end
end
