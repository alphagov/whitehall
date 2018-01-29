class AssetRemover
  def remove_government_uploads_system_uploads
    target_dir = File.join(Whitehall.clean_uploads_root, 'government', 'uploads', 'system', 'uploads')
    remove_asset_dir(target_dir)
  end

  def remove_uploaded_number10
    target_dir = File.join(Whitehall.clean_uploads_root, 'uploaded', 'number10')
    remove_asset_dir(target_dir)
  end

  def remove_organisation_logo
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'organisation', 'logo')
    remove_asset_dir(target_dir)
  end

  def remove_consultation_response_form_data_file
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'consultation_response_form_data', 'file')
    remove_asset_dir(target_dir)
  end

  def remove_classification_featuring_image_data_file
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'classification_featuring_image_data', 'file')
    remove_asset_dir(target_dir)
  end

  def remove_default_news_organisation_image_data_file
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'default_news_organisation_image_data', 'file')
    remove_asset_dir(target_dir)
  end

  def remove_feature_image
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'feature', 'image')
    remove_asset_dir(target_dir)
  end

  def remove_image_data_file
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'image_data', 'file')
    remove_asset_dir(target_dir)
  end

  def remove_person_image
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'person', 'image')
    remove_asset_dir(target_dir)
  end

  def remove_promotional_feature_item_image
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'promotional_feature_item', 'image')
    remove_asset_dir(target_dir)
  end

  def remove_take_part_page_image
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'take_part_page', 'image')
    remove_asset_dir(target_dir)
  end

private

  def remove_asset_dir(target_dir)
    FileUtils.remove_dir(target_dir)
    Dir.glob(File.join(target_dir, '**', '*'))
  end
end
