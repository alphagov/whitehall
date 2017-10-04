class Whitehall::AssetManagerStorage < CarrierWave::Storage::Abstract
  def store!(file)
    carrrierwave_file = file.to_file
    path = File.join('/government/uploads', uploader.store_path)
    Services.asset_manager.create_whitehall_asset(file: carrrierwave_file, legacy_url_path: path)
    file
  end

  def retrieve!(_identifier)
    raise "We're not currently reading assets from Asset Manager so this shouldn't be called."
  end
end
