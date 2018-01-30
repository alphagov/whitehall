namespace :asset_manager do
  desc "Migrates Assets to Asset Manager."
  task :migrate_assets, [:target_dir] => :environment do |_, args|
    abort(usage_string) unless args[:target_dir]
    migrator = MigrateAssetsToAssetManager.new(args[:target_dir])
    puts migrator
    migrator.perform
  end

  %i(remove_government_uploads_system_uploads
     remove_uploaded_number10
     remove_organisation_logo
     remove_consultation_response_form_data_file
     remove_classification_featuring_image_data_file
     remove_default_news_organisation_image_data_file
     remove_feature_image
     remove_image_data_file
     remove_person_image
     remove_promotional_feature_item_image
     remove_take_part_page_image).each do |method|
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
