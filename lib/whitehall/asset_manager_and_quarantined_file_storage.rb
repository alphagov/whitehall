class Whitehall::AssetManagerAndQuarantinedFileStorage < CarrierWave::Storage::Abstract
  def store!(file)
    Whitehall::AssetManagerStorage.new(uploader).store!(file) if Whitehall.use_asset_manager
    Whitehall::QuarantinedFileStorage.new(uploader).store!(file)
  end

  def retrieve!(identifier)
    Whitehall::QuarantinedFileStorage.new(uploader).retrieve!(identifier)
  end
end
