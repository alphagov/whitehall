desc "Identify and update corresponding replacement asset variant"
task :fix_asset_variant_replacement, %i[csv_path] => :environment do |_, args|
  csv_path = args[:csv_path]

  CSV.foreach(csv_path, headers: false) do |row|
    attachment_data_id = row[0]
    asset_manager_id = row[1]
    variant = row[2]

    attachment_data = AttachmentData.find(attachment_data_id)

    unless attachment_data.replaced?
      puts "Attachment Data ID: #{attachment_data.id}, Asset ID: #{asset_manager_id} - SKIPPED. No replacement found."
      next
    end

    replacement_id = attachment_data.replaced_by_id

    until replacement_id.nil?
      replacement_data = AttachmentData.find(replacement_id)
      replacement_id = replacement_data.replaced_by_id
    end

    begin
      replacement_id = replacement_data.assets.where(variant:).first&.asset_manager_id || replacement_data.assets.where(variant: "original").first&.asset_manager_id
      AssetManager::AssetUpdater.call(asset_manager_id, { "replacement_id" => replacement_id })

      puts "Attachment Data ID: #{attachment_data_id}, Asset ID: #{asset_manager_id}, Variant: #{variant}, Replacement ID: #{replacement_id} - OK"
    rescue StandardError => e
      puts "Attachment Data ID: #{attachment_data_id}, Asset ID #{asset_manager_id} - ERROR, message: #{e.message}"
    end
  end
end
