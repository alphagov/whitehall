class Storage::PreviewableStorage < CarrierWave::Storage::Abstract
  def store!(carrierwave_file)
    original_file = carrierwave_file.to_file
    temporary_location = Whitehall::AssetManagerStorage::TempStorage.store!(original_file)

    logger.info("Saving to Asset Manager for model #{uploader.model.class} with ID #{uploader.model.id}")

    AssetManagerCreateAssetWorker.perform_async(temporary_location, uploader.asset_params, uploader.model.auth_bypass_ids)

    Whitehall::AssetManagerStorage::File.new(uploader.store_path(::File.basename(original_file)), uploader.model, uploader.version_name)
  end

  def retrieve!(identifier)
    asset_path = uploader.store_path(identifier)
    Whitehall::AssetManagerStorage::File.new(asset_path, uploader.model, uploader.version_name)
  end
end
