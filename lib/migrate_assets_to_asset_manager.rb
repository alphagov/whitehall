class MigrateAssetsToAssetManager
  def initialize(file_paths = OrganisationLogoFilePaths.new)
    @file_paths = file_paths
  end

  def perform
    @file_paths.each do |file_path|
      file = OrganisationLogoFile.open(file_path)
      create_whitehall_asset(file) unless asset_exists?(file)
    end
  end

  private

  def create_whitehall_asset(file)
    Services.asset_manager.create_whitehall_asset(
      file: file,
      legacy_url_path: file.legacy_url_path,
      legacy_last_modified: file.legacy_last_modified,
      legacy_etag: file.legacy_etag
    )
  end

  def asset_exists?(file)
    Services.asset_manager.whitehall_asset(file.legacy_url_path)
  rescue GdsApi::HTTPNotFound
    false
  end

  class OrganisationLogoFilePaths
    delegate :each, to: :file_paths

    def file_paths
      all_paths_under_target_directory.reject { |f| File.directory?(f) }
    end

  private

    def all_paths_under_target_directory
      Dir.glob(File.join(target_dir, '**', '*'))
    end

    def target_dir
      File.join(Whitehall.clean_uploads_root, 'system', 'uploads', 'organisation', 'logo')
    end
  end

  class OrganisationLogoFile < File
    def legacy_url_path
      path.gsub(Whitehall.clean_uploads_root, '/government/uploads')
    end

    def legacy_last_modified
      File.stat(path).mtime
    end

    def legacy_etag
      Digest::MD5.hexdigest(read)
    end
  end
end
