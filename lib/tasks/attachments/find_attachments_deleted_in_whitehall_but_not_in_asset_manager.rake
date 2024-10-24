task find_attachments_deleted_in_whitehall_but_not_in_asset_manager: :environment do
  file = File.open("./lib/tasks/attachments/superseded_attachments_to_delete_in_am.txt", "a")
  problematic_content_ids = []

  CSV.foreach("./lib/tasks/attachments/attachments_deleted_in_wh_on_superseded_editions.csv", headers: true) do |row|
    content_id = row["attachment_content_id"]
    asset_manager_id = row["asset_manager_id"]
    attachment_data_id = row["attachment_data_id"]

    new_item = { "attachment_data_id" => attachment_data_id, "content_id" => content_id, "asset_manager_id" => asset_manager_id }
    next if problematic_content_ids.detect { |item| item["content_id"] == new_item["content_id"] }

    begin
      asset_manager_response = GdsApi.asset_manager.asset(asset_manager_id).to_h
    rescue GdsApi::HTTPNotFound
      next
    end

    if asset_manager_response["deleted"] == false
      puts "AttachmentData ID #{attachment_data_id} - asset_manager_id #{asset_manager_id} is NOT deleted in AM"

      problematic_content_ids << new_item
      file << new_item << "\n"
    end
  end

  file.close
end
