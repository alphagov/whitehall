class AssetManagerAttachmentDataWorker < WorkerBase
  sidekiq_options queue: 'asset_manager', unique: :until_executing

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find(attachment_data_id)
    return unless attachment_data.uploaded_to_asset_manager_at

    draft_status_updater attachment_data_id
    redirect_url_updater attachment_data_id
    link_header_updater attachment_data_id
    access_limited_updater attachment_data_id
    deleter attachment_data_id

    AttachmentData.where(replaced_by: attachment_data).find_each do |data|
      replacement_id_updater data
    end
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
