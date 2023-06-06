class AssetManagerAttachmentRedirectUrlUpdateWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return if attachment_data.blank?
    logger.info "[AssetManagerAttachmentRedirectUrlUpdateWorker]  govuk_request_id: #{GdsApi::GovukHeaders.headers[:govuk_request_id]} attachment_data_id: #{attachment_data_id}"

    AssetManager::AttachmentUpdater.call(attachment_data, redirect_url: true)
  end
end
