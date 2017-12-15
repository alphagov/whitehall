class MigrateAssetsToAssetManager
  include ActionView::Helpers::TextHelper

  def initialize(target_dir)
    @file_paths = AssetFilePaths.new(target_dir)
  end

  def perform
    @file_paths.each do |file_path|
      Worker.perform_async(file_path)
    end
  end

  def to_s
    "Migrating #{pluralize(@file_paths.size, 'file')}"
  end

  class Worker < WorkerBase
    sidekiq_options queue: :asset_migration

    def perform(file_path)
      file = AssetFile.open(file_path)
      create_whitehall_asset(file) unless asset_exists?(file)
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
  end

  class AssetFilePaths
    delegate :each, :size, to: :file_paths

    def initialize(target_dir)
      @target_dir = target_dir
    end

    def file_paths
      all_paths_under_target_directory.reject { |f| File.directory?(f) }
    end

  private

    def all_paths_under_target_directory
      Dir.glob(File.join(full_target_dir, '**', '*'))
    end

    def full_target_dir
      File.join(Whitehall.clean_uploads_root, @target_dir)
    end
  end

  class AssetFile < File
    def legacy_url_path
      path.gsub(Whitehall.clean_uploads_root, '/government/uploads')
    end

    def legacy_last_modified
      File.stat(path).mtime
    end

    def legacy_etag
      '%x-%x' % [legacy_last_modified, size]
    end
  end
end
