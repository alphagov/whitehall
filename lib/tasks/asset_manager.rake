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

  namespace :attachments do
    desc 'Update draft status for Asset Manager assets associated with attachments'
    task :update_draft_status, %i(first_id last_id) => :environment do |_, args|
      first_id = args[:first_id]
      last_id = args[:last_id]
      abort(update_draft_status_usage_string) unless first_id && last_id
      options = { start: first_id, finish: last_id }
      updater = ServiceListeners::AttachmentDraftStatusUpdater
      FileAttachment.includes(:attachment_data).find_each(options) do |attachment|
        if File.exist?(attachment.attachment_data.file.path)
          updater.new(attachment.attachment_data, queue: 'asset_migration').update!
        end
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

  def update_draft_status_usage_string
    %{Usage: asset_manager:attachments:update_draft_status[<first_id>,<last_id>]

      Where <first_id> and <last_id> are Attachment database IDs.
    }
  end
end
