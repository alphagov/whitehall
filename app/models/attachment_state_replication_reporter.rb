class AttachmentStateReplicationReporter
  attr_reader :errors

  def initialize(asset_manager_client)
    @client = asset_manager_client
    @errors = []
  end

  # An asset should be live if:
  #   its attachment data has an attachment with an attachable which is published or withdrawn and the attachment is not deleted
  # An asset should be redirected if:
  #   its attachment data has an attachment with an attachable which is unpublished and the attachment is not deleted
  # An asset should not be live if its attachment data does not have an attachment in one of the above states or if it has been replaced
  def run
    live_asset_query_results.each do |result|
      next if result["asset_manager_id"].nil?

      response = @client.media(result["asset_manager_id"], result["filename"])

      # The asset should be redirected (i.e. the response history should not be empty) if the attachable is unpublished
      if result["attachable_state"] == "unpublished" && response.history.empty?
        errors << {
          asset_manager_id: result["asset_manager_id"],
          filename: result["filename"],
          attachment_data_id: result["ad_id"],
          message: "Asset missing redirect",
        }
        next
      end

      # The asset should be live if the attachable is published or withdrawn
      next unless response.code != 200

      errors << {
        asset_manager_id: result["asset_manager_id"],
        filename: result["filename"],
        attachment_data_id: result["ad_id"],
        message: "Asset not found",
      }
    end

    non_live_asset_query_results.each do |result|
      next if result["asset_manager_id"].nil?

      response = @client.media(result["asset_manager_id"], result["filename"])

      if result["replaced_by_id"].present? && (response.code == 200 && response.history.empty?)
        errors << {
          asset_manager_id: result["asset_manager_id"],
          filename: result["filename"],
          attachment_data_id: result["ad_id"],
          message: "Asset missing redirect",
        }
        next
      end

      next unless response.code == 200

      errors << {
        asset_manager_id: result["asset_manager_id"],
        filename: result["filename"],
        attachment_data_id: result["ad_id"],
        message: "Asset should not be live",
      }
    end
  end

  def live_asset_query
    <<~SQL
      select attachment_data.id as ad_id, assets.filename, assets.asset_manager_id, attachments.deleted as attachment_deleted, editions.state as attachable_state from attachment_data
      join attachments on attachments.attachment_data_id = attachment_data.id
      join assets on assets.assetable_id = attachment_data.id and assets.assetable_type = 'AttachmentData'
      join editions on editions.id = attachments.attachable_id and attachments.attachable_type = 'Edition'
      where editions.state IN('published', 'withdrawn', 'unpublished')
      and attachments.deleted = false
      and editions.updated_at > DATE_SUB(NOW(), INTERVAL 1 YEAR)
    SQL
  end

  def live_asset_query_results
    ActiveRecord::Base.connection.exec_query(live_asset_query).to_a
  end

  def non_live_asset_query
    <<-SQL
        select attachment_data.id as ad_id, attachment_data.replaced_by_id, assets.filename, assets.asset_manager_id from attachment_data
        left join attachments on attachments.attachment_data_id = attachment_data.id
        join assets on assets.assetable_id = attachment_data.id and assets.assetable_type = 'AttachmentData'
        join editions on editions.id = attachments.attachable_id and attachments.attachable_type = 'Edition'
        and editions.updated_at > DATE_SUB(NOW(), INTERVAL 1 YEAR)
        and attachment_data.id not in (?)
    SQL
  end

  def non_live_asset_query_results
    live_attachment_data_ids = live_asset_query_results.map { |result| result["ad_id"] }
    ActiveRecord::Base.connection.exec_query(non_live_asset_query, "not live query", [live_attachment_data_ids.join(", ")]).to_a
  end

  def report
    # Send errors to Zendesk
  end
end
