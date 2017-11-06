namespace :asset_manager do
  desc "Migrates Assets to Asset Manager."
  task migrate_assets: :environment do
    MigrateAssetsToAssetManager.new.perform
  end
end
