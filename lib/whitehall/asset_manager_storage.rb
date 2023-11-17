class Whitehall::AssetManagerStorage < CarrierWave::Storage::Abstract
  def store!(file)
    original_file = file.to_file
    temporary_location = ::File.join(
      Whitehall.asset_manager_tmp_dir,
      SecureRandom.uuid,
      ::File.basename(original_file),
    )

    FileUtils.mkdir_p(::File.dirname(temporary_location))
    FileUtils.cp(original_file, temporary_location)
    legacy_url_path = ::File.join("/government/uploads", uploader.store_path)
    draft = uploader.assets_protected?

    if uploader.model.respond_to?(:attachable)
      attachable_model_class = uploader.model.attachable && uploader.model.attachable.class.to_s
      attachable_model_id = uploader.model.attachable && uploader.model.attachable.id
    end

    auth_bypass_ids = uploader.model.respond_to?(:auth_bypass_ids) ? uploader.model.auth_bypass_ids : []

    logger.info("Saving to Asset Manager for model #{uploader.model.class} with ID #{uploader.model&.id || 'nil'}")

    if Whitehall::AssetManagerStorage.use_non_legacy_behaviour?(uploader.model)
      assetable_id = uploader.model.id
      assetable_type = uploader.model.class.to_s
      asset_variant = uploader.version_name ? Asset.variants[uploader.version_name] : Asset.variants[:original]
      asset_params = { assetable_id:, asset_variant:, assetable_type: }.deep_stringify_keys

      # Separating the journey based on feature flag so its easier to make future changes and also decommission old journey
      AssetManagerCreateAssetWorker.perform_async(temporary_location, asset_params, draft, attachable_model_class, attachable_model_id, auth_bypass_ids)
    else
      AssetManagerCreateWhitehallAssetWorker.perform_async(temporary_location, legacy_url_path, draft, attachable_model_class, attachable_model_id, auth_bypass_ids)
    end

    File.new(uploader.store_path, uploader.model, uploader.version_name)
  end

  def retrieve!(identifier)
    asset_path = uploader.store_path(identifier)
    File.new(asset_path, uploader.model, uploader.version_name)
  end

  class File
    def initialize(asset_path, model = nil, version_name = nil)
      @version = version_name
      @model = model
      @asset_path = asset_path
      @legacy_url_path = ::File.join("/government", "uploads", asset_path)
    end

    def delete
      if Whitehall::AssetManagerStorage.use_non_legacy_behaviour?(@model)
        asset = get_asset
        if asset
          AssetManagerDeleteAssetWorker.perform_async(nil, asset.asset_manager_id)
        end
      else
        AssetManagerDeleteAssetWorker.perform_async(@legacy_url_path, nil)
      end
    end

    def url
      if Whitehall::AssetManagerStorage.use_non_legacy_behaviour?(@model)
        asset = get_asset
        if asset
          URI.join(Plek.asset_root, Addressable::URI.encode("media/#{asset.asset_manager_id}/#{asset.filename}")).to_s
        end
      else
        URI.join(Plek.asset_root, Addressable::URI.encode(@legacy_url_path)).to_s
      end
    end

    def path
      @legacy_url_path
    end

    def filename
      ::File.basename(@asset_path)
    end

    def asset_manager_path
      path
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

  def self.use_non_legacy_behaviour?(model)
    return unless model

    return true if model.instance_of?(AttachmentData) || model.instance_of?(ImageData) || model.instance_of?(Organisation) || model.instance_of?(FeaturedImageData) || model.instance_of?(TopicalEventFeaturingImageData) || model.instance_of?(PromotionalFeatureItem)

    model.respond_to?("use_non_legacy_endpoints") && model.use_non_legacy_endpoints
  end
end
