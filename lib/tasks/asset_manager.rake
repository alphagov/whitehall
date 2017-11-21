namespace :asset_manager do
  desc "Migrates Assets to Asset Manager."
  task :migrate_assets, [:target_dir] => :environment do |_, args|
    abort(usage_string) unless args[:target_dir]
    migrator = MigrateAssetsToAssetManager.new(args[:target_dir])
    puts migrator
    migrator.perform
  end

  desc "Removes all organisation logos."
  task remove_organisation_logos: :environment do
    AssetRemover.new.remove_organisation_logos
  end

  private

  def usage_string
    %{Usage: asset_manager:migrate_assets[<path>]

      Where <path> is a subdirectory under Whitehall.clean_uploads_root e.g. `system/uploads/organisation/logo`
    }
  end
end
