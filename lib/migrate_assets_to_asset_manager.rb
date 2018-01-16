class MigrateAssetsToAssetManager
  include ActionView::Helpers::TextHelper

  def initialize(target_dir)
    @relative_file_paths = AssetFilePaths.new(target_dir)
  end

  def perform
    @relative_file_paths.each do |relative_file_path|
      Worker.perform_async(relative_file_path)
    end
  end

  def to_s
    "Migrating #{pluralize(@relative_file_paths.size, 'file')}"
  end

  class Worker < WorkerBase
    sidekiq_options queue: :asset_migration

    def perform(relative_file_path)
      absolute_file_path = File.join(Whitehall.clean_uploads_root, relative_file_path)
      AssetFile.open(absolute_file_path) do |file|
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
  end

  class AssetFilePaths
    delegate :each, :size, to: :relative_file_paths

    def initialize(target_dir)
      @target_dir = target_dir
    end

    def relative_file_paths
      absolute_file_paths.map { |p| path_relative_to_clean_uploads_root(p) }
    end

  private

    def path_relative_to_clean_uploads_root(path)
      Pathname.new(path).relative_path_from(Pathname.new(Whitehall.clean_uploads_root)).to_s
    end

    def absolute_file_paths
      all_paths_under_target_directory.reject { |f| File.directory?(f) }
    end

    def all_paths_under_target_directory
      Dir.glob(File.join(full_target_dir, '**', '*'), File::FNM_DOTMATCH)
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
