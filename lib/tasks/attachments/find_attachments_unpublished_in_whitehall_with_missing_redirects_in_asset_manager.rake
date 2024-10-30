desc "Identify all AttachmentData instances where ...."
task find_attachments_unpublished_in_whitehall_with_missing_redirects_in_asset_manager: :environment do
  file = File.open("./lib/tasks/attachments/attachments_to_redirect_in_am.txt", "a")
  # to run AssetManagerAttachmentRedirectUrlUpdateWorker.perform_async(attachment.attachment_data.id) => we require attachment datas
  problematic_content_ids = []

  CSV.foreach("./lib/tasks/attachments/attachments_on_unpublished_editions.csv", headers: true) do |row|
    asset_manager_id = row["asset_manager_id"]
    attachment_data_id = row["attachment_data_id"]

    new_item = { "attachment_data_id" => attachment_data_id, "asset_manager_id" => asset_manager_id }
    next if problematic_content_ids.detect { |item| item["attachment_data_id"] == new_item["attachment_data_id"] }

    begin
      asset_manager_response = GdsApi.asset_manager.asset(asset_manager_id).to_h
    rescue GdsApi::HTTPNotFound
      next
    end

    if asset_manager_response["redirect_url"].nil?
      puts "AttachmentData ID #{attachment_data_id} - asset_manager_id #{asset_manager_id} is NOT redirected in AM"

      problematic_content_ids << new_item
      file << new_item << "\n"
    end
  end

  file.close
end

