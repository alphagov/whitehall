desc "Report on all deleted? AttachmentData in Whitehall"
task report_on_all_deleted_attachment_data_assets: :environment do
  file1 = File.open("./lib/tasks/attachments/attachment_data_deleted_in_wh_with_assets_not_deleted_in_am.txt", "a")
  file2 = File.open("./lib/tasks/attachments/attachment_data_deleted_and_replaced_in_wh_with_assets_not_deleted_in_am.txt", "a")

  AttachmentData.find_each.map do |attachment_data|
    next unless attachment_data.attachments.first&.attachable.is_a?(Edition)
    next unless attachment_data.deleted?

    attachment_data.assets.map do |asset|
      begin
        asset_manager_response = GdsApi.asset_manager.asset(asset.asset_manager_id).to_h
      rescue GdsApi::HTTPNotFound
        next
      end

      next unless asset_manager_response["deleted"] == false

      if attachment_data.replaced_by_id
        replaced = !asset_manager_response["replacement_id"].nil?
        puts "AttachmentData #{attachment_data.id} deleted and replaced in WH, asset #{asset.asset_manager_id} not deleted in AM, replaced: #{replaced}"

        file2 << "#{attachment_data.id},#{asset.asset_manager_id},#{replaced},#{attachment_data.updated_at}" << "\n"
      else
        puts "AttachmentData #{attachment_data.id} deleted in WH, asset #{asset.asset_manager_id} not deleted in AM, redirect: #{!asset_manager_response['redirect_url'].nil?}"

        file1 << "#{attachment_data.id},#{asset.asset_manager_id},#{asset_manager_response['redirect_url'] || 'no redirect'},#{attachment_data.updated_at}" << "\n"
      end
    end
  end

  file1.close
  file2.close
end
