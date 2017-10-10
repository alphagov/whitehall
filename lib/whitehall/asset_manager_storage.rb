class Whitehall::AssetManagerStorage < CarrierWave::Storage::Abstract
  def store!(file)
    original_file = file.to_file
    temporary_location = File.join(
      Whitehall.asset_manager_tmp_dir,
      SecureRandom.uuid,
      File.basename(original_file)
    )

    FileUtils.mkdir_p(File.dirname(temporary_location))
    FileUtils.cp(original_file, temporary_location)
    legacy_url_path = File.join('/government/uploads', uploader.store_path)
    AssetManagerWorker.perform_async(temporary_location, legacy_url_path)
    file
  end

  def retrieve!(_identifier)
    raise "We're not currently reading assets from Asset Manager so this shouldn't be called."
  end
end
