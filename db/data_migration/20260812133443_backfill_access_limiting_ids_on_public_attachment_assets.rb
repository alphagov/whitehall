attachment_data_scope = AttachmentData
                          .joins(:attachments)
                          .where(attachments: { attachable_type: "Edition", attachable_id: Edition.where(state: %w[published withdrawn]).select(:id) })
                          .distinct

total = attachment_data_scope.count
started_at = Time.current

attachment_data_scope.find_each do |attachment_data|
  AssetManagerAttachmentMetadataJob.perform_async_in_queue("asset_manager_updater", attachment_data.id)
end

puts "Queued Asset Manager metadata refresh for #{total} attachments in #{(Time.current - started_at).round(2)}s"
