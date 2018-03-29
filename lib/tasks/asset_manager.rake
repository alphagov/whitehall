namespace :asset_manager do
  desc "Migrates Assets to Asset Manager."
  task :migrate_assets, [:target_dir] => :environment do |_, args|
    abort(usage_string) unless args[:target_dir]
    migrator = MigrateAssetsToAssetManager.new(args[:target_dir])
    puts migrator
    migrator.perform
  end

  desc "Migrate assets under system/uploads/attachment_data/file to Asset Manager"
  task :migrate_attachments, %i(batch_start batch_end) => :environment do |_, args|
    abort(migrate_attachments_usage_string) unless args[:batch_start] && args[:batch_end]
    MigrateAssetsToAssetManager.migrate_attachments(args[:batch_start].to_i, args[:batch_end].to_i)
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

  task :update_attachment_metadata, %i(batch_start batch_end) => :environment do |_, args|
    abort(update_attachment_metadata_usage_string) unless args[:batch_start] && args[:batch_end]
    AssetManagerAttachmentMetadataUpdater.update_range(args[:batch_start].to_i, args[:batch_end].to_i)
  end

  task generate_missing_thumbnails: :environment do
    [332963, 310979, 199066, 318696, 311266, 321710, 199068, 326576, 69897, 417180, 371318, 501885, 418558].each do |id|
      begin
        attachment_data = AttachmentData.find(id)
        attachment_data.file.recreate_versions!
      rescue ActiveRecord::RecordNotFound => e
        puts e
      end
    end
  end

  private

  def usage_string
    %{Usage: asset_manager:migrate_assets[<path>]

      Where <path> is a subdirectory under Whitehall.clean_uploads_root e.g. `system/uploads/organisation/logo`
    }
  end

  def migrate_attachments_usage_string
    %{Usage: asset_manager:migrate_attachments[<batch_start>,<batch_end>]

      Where <batch_start> and <batch_end> are integers corresponding to the directory names under `system/uploads/attachment_data/file`. e.g. `system/uploads/attachment_data/file/100` will be migrated if <batch_start> <= 100 and <batch_end> >= 100.
    }
  end

  def update_attachment_metadata_usage_string
    lowest_id = AttachmentData.order(:id).first.id
    highest_id = AttachmentData.order(:id).last.id

    %{Usage: asset_manager:update_attachment_metadata[<batch_start>,<batch_end>]

      Where <batch_start> and <batch_end> are integers between #{lowest_id} and #{highest_id} corresponding to the primary key of the AttachmentData records in the database.
    }
  end
end
