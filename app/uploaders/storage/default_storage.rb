class Storage::DefaultStorage < CarrierWave::Storage::Abstract
  def store!(file)
    original_file = file.to_file
    temporary_location = ::File.join(
      Whitehall.asset_manager_tmp_dir,
      SecureRandom.uuid,
      ::File.basename(original_file),
    )

    FileUtils.mkdir_p(::File.dirname(temporary_location))
    FileUtils.cp(original_file, temporary_location)

    logger.info("Saving to Asset Manager for model #{uploader.model.class} with ID #{uploader.model.id}")

    asset_variant = uploader.version_name ? Asset.variants[uploader.version_name] : Asset.variants[:original]
    asset_params = { assetable_id: uploader.model.id, asset_variant:, assetable_type: uploader.model.class.to_s }.deep_stringify_keys

    AssetManagerCreateAssetWorker.perform_async(temporary_location, asset_params)

    Whitehall::AssetManagerStorage::File.new(uploader.store_path(::File.basename(original_file)), uploader.model, uploader.version_name)
  end

  def retrieve!(identifier)
    asset_path = uploader.store_path(identifier)
    Whitehall::AssetManagerStorage::File.new(asset_path, uploader.model, uploader.version_name)
  end
end
