desc "Find attachments marked as deleted in whitehall but not in Asset Manager"
task :find_attachments_deleted_in_whitehall_but_not_in_asset_manager, [:editions_state] => :environment do |_, args|
  # Valid edition states are: published, withdrawn, superseded, draft.
  # We can have attachments marked as deleted for attachables in all those states, which should be deleted in AssetManager.
  # This rake task should be run on a well constructed set of data. We've run it on the back of SQL queries.
  # If the AttachmentData `deleted?` method returns true for the values provided in the csv, then the associated assets should be deleted.
  # Note that for draft state attachments should only be deleted if that is the first draft of a document.

  editions_state = args[:editions_state]

  file = File.open("./lib/tasks/attachments/#{editions_state}_attachments_to_delete_in_am.txt", "a")
  problematic_content_ids = []

  CSV.foreach("./lib/tasks/attachments/attachments_deleted_in_wh_on_#{editions_state}_editions.csv", headers: true) do |row|
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
