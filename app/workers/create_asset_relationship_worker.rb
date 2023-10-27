class CreateAssetRelationshipWorker < WorkerBase
  def perform(start_id, end_id)
    logger.info("CreateAssetRelationshipWorker start!")

    assetable_type = FeaturedImageData.name

    organisations = Organisation.where(id: start_id..end_id).where("default_news_organisation_image_data_id is not null")

    logger.info "Number of #{assetable_type} found: #{organisations.count}"
    logger.info "Creating Asset for records from #{start_id} to #{end_id}"

    variants = %i[original s960 s712 s630 s465 s300 s216]
    assetables_count = 0
    asset_counter = 0

    organisations.each do |organisation|
      variants.each do |variant|
        legacy_path = get_legacy_path(organisation.default_news_image.file, variant)
        asset_info = get_whitehall_asset_data(legacy_path)
        save_asset_id_to_assets(organisation.default_news_image_new.id, assetable_type, Asset.variants[variant], asset_info[:asset_manager_id], asset_info[:filename])
        asset_counter += 1
      rescue GdsApi::HTTPNotFound
        logger.warn "#{assetable_type} of id##{organisation.id} - could not find asset variant :#{variant} at path #{legacy_path}"
      end
      assetables_count += 1
    end

    logger.info("Created assets for #{assetables_count} assetable")
    logger.info("Created asset counter #{asset_counter}")
    logger.info("CreateAssetRelationshipWorker finish!")

    { assetables_count:, asset_counter: }
  end

private

  def get_legacy_path(file, variant)
    variant == :original ? file.path : file.versions[variant].path
  end

  def asset_manager
    Services.asset_manager
  end

  def get_whitehall_asset_data(legacy_url_path)
    asset_info = {}
    path = legacy_url_path.sub(/^\//, "")
    response_hash = asset_manager.whitehall_asset(path).to_hash
    asset_info[:asset_manager_id] = get_asset_id(response_hash)
    asset_info[:filename] = get_filename(response_hash)
    asset_info
  end

  def get_filename(response)
    response["name"]
  end

  def get_asset_id(response)
    url = response["id"]
    url[/\/assets\/(.*)/, 1]
  end

  def save_asset_id_to_assets(assetable_id, assetable_type, variant, asset_manager_id, filename)
    asset = Asset.new(asset_manager_id:, assetable_type:, assetable_id:, variant:, filename:)
    asset.save!
  end
end
