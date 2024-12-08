desc "Identify all AttachmentData instances where attachable is unpublished but there are missing redirects in AM"
task find_attachments_unpublished_in_whitehall_with_missing_redirects_in_asset_manager: :environment do
  file = File.open("./lib/tasks/attachments/attachments_without_redirects_in_am.txt", "a")

  CSV.foreach("./lib/tasks/attachments/attachments_on_unpublished_editions.csv", headers: true) do |row|
    asset_manager_id = row["asset_manager_id"]
    attachment_data_id = row["attachment_data_id"]

    begin
      am_response = GdsApi.asset_manager.asset(asset_manager_id).to_h
    rescue GdsApi::HTTPNotFound
      next
    end

    if am_response["redirect_url"].nil?
      attachment_data = AttachmentData.find(attachment_data_id)
      document_id = attachment_data&.attachments&.first&.attachable&.document_id
      variant = attachment_data.assets.select { |a| a["asset_manager_id"] == asset_manager_id }.first.variant

      puts "ad: #{attachment_data_id}, am_id: #{asset_manager_id}, d_id: #{document_id}, var: #{variant}, draft: #{am_response['draft']}, deleted: #{am_response['deleted']}, replaced: #{!am_response['replacement_id'].nil?}, year: #{attachment_data.created_at.year}"
      file << "#{attachment_data_id},#{asset_manager_id},#{document_id},#{variant},#{am_response['draft']},#{am_response['deleted']},#{!am_response['replacement_id'].nil?},#{attachment_data.created_at.year}" << "\n"
    end
  end

  file.close
end
