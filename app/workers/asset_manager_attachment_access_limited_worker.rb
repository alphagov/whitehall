class AssetManagerAttachmentAccessLimitedWorker < WorkerBase
  sidekiq_options queue: 'asset_manager'

  def perform(attachment_data_id)
    attachment_data = AttachmentData.find_by(id: attachment_data_id)
    return unless attachment_data.present?
    access_limited_to_these_users = []
    if attachment_data.access_limited?
      access_limited_to_these_users = AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
    end

    enqueue_job(attachment_data, attachment_data.file, access_limited_to_these_users)
    if attachment_data.pdf?
      enqueue_job(attachment_data, attachment_data.file.thumbnail, access_limited_to_these_users)
    end
  end

private

  def enqueue_job(attachment_data, uploader, access_limited_to_these_users)
    legacy_url_path = uploader.asset_manager_path
    AssetManagerUpdateAssetWorker.new.perform(attachment_data, legacy_url_path, "access_limited" => access_limited_to_these_users)
  end
end
