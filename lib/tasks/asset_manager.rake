namespace :asset_manager do
  desc "Migrates Assets to Asset Manager."
  task :migrate_assets, [:target_dir] => :environment do |_, args|
    abort(usage_string) unless args[:target_dir]
    migrator = MigrateAssetsToAssetManager.new(args[:target_dir])
    puts migrator
    migrator.perform
  end

  task migrate_attachments: :environment do
    MigrateAssetsToAssetManager.migrate_attachments
  end

  %i(remove_attachment_file
     remove_consultation_response_form_file
     remove_edition_organisation_image_data_file
     remove_edition_world_location_image_data_file
     remove_news_article_featuring_image
     remove_news_article_image
     remove_topical_event_logo).each do |method|
    desc "Calls AssetRemover##{method}."
    task method => :environment do
      files = AssetRemover.new.send(method)
      puts "#{files.size} files remaining"
    end
  end

  private

  def usage_string
    %{Usage: asset_manager:migrate_assets[<path>]

      Where <path> is a subdirectory under Whitehall.clean_uploads_root e.g. `system/uploads/organisation/logo`
    }
  end
end
