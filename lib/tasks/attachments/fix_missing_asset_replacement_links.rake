desc "Fix missing replacement links"
task :fix_missing_asset_replacement_links, %i[csv_path] => :environment do |_, args|
  csv_path = args[:csv_path]

  CSV.foreach(csv_path, headers: false) do |row|
    attachment_data_id = row[0]
    attachment_data = AttachmentData.find(attachment_data_id)

    if attachment_data.replaced_by_id.nil?
      puts "ERROR - ad: #{attachment_data.id} does not have a replacement."
      next
    end

    begin
      AssetManager::AttachmentUpdater.replace(attachment_data)
      puts "OK - ad: #{attachment_data_id}"
    rescue StandardError => e
      puts "ERROR - ad: #{attachment_data_id}, message: #{e.message}"
    end
  end
end
