class AssetManagerAttachmentDataWorker < WorkerBase
  sidekiq_options queue: 'asset_manager'

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)
    return unless attachment_data.uploaded_to_asset_manager_at
    return if attachment_data.synchronised_with_asset_manager?

    draft_status_updater attachment_data_id
    redirect_url_updater attachment_data_id
    link_header_updater attachment_data_id
    access_limited_updater attachment_data_id
    deleter attachment_data_id

    AttachmentData.where(replaced_by: attachment_data).find_each do |data|
      replacement_id_updater data
    end

    # ideally attachment data would have a version field, and we'd
    # record which version we sent to the asset manager
    attachment_data.synchronised_with_asset_manager_at = attachment_data.updated_at
    attachment_data.save!
  end

private

  def draft_status_updater(attachment_data_id)
    AssetManagerAttachmentDraftStatusUpdateWorker.new.perform attachment_data_id
  end

  def redirect_url_updater(attachment_data_id)
    AssetManagerAttachmentRedirectUrlUpdateWorker.new.perform attachment_data_id
  end

  def link_header_updater(attachment_data_id)
    AssetManagerAttachmentLinkHeaderUpdateWorker.new.perform(attachment_data_id)
  end

  def access_limited_updater(attachment_data_id)
    AssetManagerAttachmentAccessLimitedWorker.new.perform(attachment_data_id)
  end

  def replacement_id_updater(attachment_data_id)
    AssetManagerAttachmentReplacementIdUpdateWorker.new.perform(attachment_data_id)
  end

  def deleter(attachment_data_id)
    AssetManagerAttachmentDeleteWorker.new.perform(attachment_data_id)
  end
end
