desc "Report on AttachmentData in WH that should be marked as deleted"
task find_all_superseded_not_deleted_replaced_in_wh_but_not_in_am: :environment do
  file = File.open("./lib/tasks/attachments/find_all_superseded_not_deleted_replaced_in_wh_but_not_in_am.txt", "a")

  AttachmentData.find_each.map do |attachment_data|
    next if attachment_data.replaced_by_id.nil?

    attachables = attachment_data.attachments.map(&:attachable).compact

    next unless attachables.any?
    next if attachables.detect { |attachable| !attachable.is_a?(Edition) }
    next if (attachables.map(&:state) - %w[superseded]).any?

    next unless attachment_data.deleted?

    attachment_data.assets.map do |asset|
      begin
        asset_manager_response = GdsApi.asset_manager.asset(asset.asset_manager_id).to_h
      rescue GdsApi::HTTPNotFound
        next
      end

      am_replacement = asset_manager_response["replacement_id"]
      next unless am_replacement.nil?

      puts "AD: #{attachment_data.id}, asset_manager_id: #{asset.asset_manager_id}"
      file << "#{attachment_data.id},#{asset.asset_manager_id}" << "\n"
    end
  end

  file.close
end
