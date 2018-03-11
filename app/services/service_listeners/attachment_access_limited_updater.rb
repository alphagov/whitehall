module ServiceListeners
  class AttachmentAccessLimitedUpdater
    attr_reader :attachment, :queue

    def initialize(attachment, queue: nil)
      @attachment = attachment
      @queue = queue
    end

    def update!
      attachment_data = attachment.attachment_data
      return unless attachment_data.present?

      access_limited = []
      if attachment_data.access_limited?
        access_limited = AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
      end

      enqueue_job(attachment_data.file, access_limited)
      if attachment_data.pdf?
        enqueue_job(attachment_data.file.thumbnail, access_limited)
      end
    end

  private

    def enqueue_job(uploader, access_limited)
      legacy_url_path = uploader.asset_manager_path
      worker.perform_async(legacy_url_path, access_limited: access_limited)
    end

    def worker
      worker = AssetManagerUpdateAssetWorker
      queue.present? ? worker.set(queue: queue) : worker
    end
  end
end
