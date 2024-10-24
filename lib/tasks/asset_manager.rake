namespace :asset_manager do
  desc "Report on attachments that are only attached to non-visible editions in Whitehall but not deleted in Asset Manager"
  task report_deleted_assets: :environment do
    output = AttachmentData.find_each.map do |attachment_data|
      attachables = attachment_data.attachments.map(&:attachable).compact

      next unless attachables.any?
      next if attachables.detect { |attachable| !attachable.is_a?(Edition) }
      next if (attachables.map(&:state) - %w[superseded]).any?

      attachment_data.assets.map do |asset|
        begin
          asset_manager_response = GdsApi.asset_manager.asset(asset.asset_manager_id).to_h
        rescue GdsApi::HTTPNotFound
          next
        end

        next unless asset_manager_response["deleted"] == false

        # return the content ID of any of the attachments (it's the same)
        attachment_data.attachments.last.content_id
      end
    end

    puts output.compact
  end
end
