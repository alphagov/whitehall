namespace :asset_manager do
  desc "Migrates Organisation logos to Asset Manager."
  task migrate_organisation_logos: :environment do
    MigrateAssetsToAssetManager.new.perform
  end
end
