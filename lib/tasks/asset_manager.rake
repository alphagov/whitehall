namespace :asset_manager do
  desc "Report on attachments that are only attached to non-visible editions in Whitehall but not deleted in Asset Manager"
  task report_deleted_assets: :environment do
    output = AttachmentData.find_each.map do |attachment_data|
      attachables = attachment_data.attachments.map(&:attachable).compact

      next unless attachables.any?
      next if attachables.detect { |attachable| !attachable.is_a?(Edition) }
      next if (attachables.map(&:state) - %w[unpublished superseded]).any?

      attachment_data.assets.map do |asset|
        asset_manager_response = GdsApi.asset_manager.asset(asset.asset_manager_id).to_h

        next unless asset_manager_response["deleted"] == false

        {
          asset_url: asset_manager_response["file_url"],
          document_path: attachables.last.public_url,
          edition_state: attachables.last.state,
        }
      end
    end

    output.flatten.compact.each do |item|
      puts [item[:asset_url], item[:document_path], item[:edition_state]].join(",")
    end
  end
end
