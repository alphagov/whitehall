class AssetRemover
  def remove_organisation_logos
    target_dir = File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'organisation', 'logo')
    files = Dir.glob(File.join(target_dir, '**', '*'))
    FileUtils.remove_dir(target_dir)
    files
  end
end
