class Whitehall::AssetManagerStorage < CarrierWave::Storage::Abstract
  def store!(file)
    temporary_location = TempDir.store!(file)

    AssetManagerCreateAssetWorker.perform_async_upload(temporary_location, uploader)

    File.new(uploader.store_path, uploader.model, uploader.version_name)
  end

  def retrieve!(identifier)
    asset_path = uploader.store_path(identifier)
    File.new(asset_path, uploader.model, uploader.version_name)
  end

  class File
    def initialize(store_path, model = nil, version_name = nil)
      @version = version_name
      @model = model
      @store_path = store_path
    end

    def delete
      asset = get_asset
      if asset
        AssetManagerDeleteAssetWorker.perform_async(asset.asset_manager_id)
      end
    end

    def url
      asset = get_asset
      if asset
        URI.join(Plek.asset_root, Addressable::URI.encode("media/#{asset.asset_manager_id}/#{asset.filename}")).to_s
      end
    end

    def path
      # We keep this because carrierwave needs this in after commit hook
      # to look for previous files to delete
      @store_path
    end

    def filename
      ::File.basename(@store_path)
    end

    def content_type
      MIME::Types.type_for(filename).first.to_s
    end

    def zero_size?
      false
    end

  private

    def get_asset
      asset_variant = @version ? Asset.variants[@version] : Asset.variants[:original]
      @model.assets.select { |a| a.variant == asset_variant }.first
    end
  end

  class TempDir
    def self.store!(carrierwave_file)
      original_file = carrierwave_file.to_file
      temporary_location = ::File.join(
        Whitehall.asset_manager_tmp_dir,
        SecureRandom.uuid,
        ::File.basename(original_file),
        )

      FileUtils.mkdir_p(::File.dirname(temporary_location))
      FileUtils.cp(original_file, temporary_location)
      temporary_location
    end
  end
end
