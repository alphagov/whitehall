class MigrateAssetsToAssetManager
  def initialize(files = OrganisationLogoFiles.new)
    @files = files
  end

  def perform
    @files.each do |file|
      Services.asset_manager.create_whitehall_asset(
        file: file,
        legacy_url_path: file.legacy_url_path,
        legacy_last_modified: file.legacy_last_modified
      )
    end
  end

  class OrganisationLogoFiles
    delegate :each, to: :files

    def files
      file_paths.map { |f| OrganisationLogoFile.open(f) }
    end

    private

    def file_paths
      all_paths_under_target_directory.reject { |f| File.directory?(f) }
    end

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
  end
end
