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
