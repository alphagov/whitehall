class AssetRemover
  def remove_attachment_file
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'attachment', 'file')
    remove_asset_dir(target_dir)
  end

  def remove_consultation_response_form_file
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'consultation_response_form', 'file')
    remove_asset_dir(target_dir)
  end

  def remove_edition_organisation_image_data_file
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'edition_organisation_image_data', 'file')
    remove_asset_dir(target_dir)
  end

  def remove_edition_world_location_image_data_file
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'edition_world_location_image_data', 'file')
    remove_asset_dir(target_dir)
  end

  def remove_news_article_featuring_image
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'news_article', 'featuring_image')
    remove_asset_dir(target_dir)
  end

  def remove_news_article_image
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'news_article', 'image')
    remove_asset_dir(target_dir)
  end

  def remove_topical_event_logo
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'topical_event', 'logo')
    remove_asset_dir(target_dir)
  end

private

  def remove_asset_dir(target_dir)
    FileUtils.remove_dir(target_dir)
    Dir.glob(File.join(target_dir, '**', '*'))
  end
end
