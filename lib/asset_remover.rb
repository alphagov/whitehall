class AssetRemover
  def remove_organisation_logos
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'organisation', 'logo')
    FileUtils.remove_dir(target_dir)
  end
end
