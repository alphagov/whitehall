class Whitehall::AssetManagerStorage < CarrierWave::Storage::Abstract
  def store!(file)
    original_file = file.to_file
    temporary_location = ::File.join(
      Whitehall.asset_manager_tmp_dir,
      SecureRandom.uuid,
      ::File.basename(original_file)
    )

    FileUtils.mkdir_p(::File.dirname(temporary_location))
    FileUtils.cp(original_file, temporary_location)
    legacy_url_path = ::File.join('/government/uploads', uploader.store_path)
    AssetManagerCreateWhitehallAssetWorker.perform_async(temporary_location, legacy_url_path)
    File.new(uploader.store_path)
  end

  def retrieve!(identifier)
    asset_path = uploader.store_path(identifier)
    File.new(asset_path)
  end

  class File
    def initialize(asset_path)
      @legacy_url_path = ::File.join('/government', 'uploads', asset_path)
    end

    def delete
      AssetManagerDeleteAssetWorker.perform_async(@legacy_url_path)
    end

    def url
      URI.join(Plek.new.public_asset_host, @legacy_url_path).to_s
    end

    def filename
      @legacy_url_path
    end

    def path
      @legacy_url_path
    end

    def content_type
      MIME::Types.type_for(filename).first.to_s
    end
  end
end
