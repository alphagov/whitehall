module ServiceListeners
  class AttachmentLinkHeaderUpdater
    attr_reader :attachment, :queue

    def initialize(attachment, queue: nil)
      @attachment = attachment
      @queue = queue
    end

    def update!
      attachment_data = attachment.attachment_data
      return unless attachment_data.present?
      return unless attachment.attachable.is_a?(Edition)

      parent_document_url = Whitehall.url_maker.public_document_url(attachment.attachable)

      enqueue_job(attachment_data.file, parent_document_url)
      if attachment_data.pdf?
        enqueue_job(attachment_data.file.thumbnail, parent_document_url)
      end
    end

  private

    def enqueue_job(uploader, parent_document_url)
      legacy_url_path = uploader.asset_manager_path
      worker.perform_async(legacy_url_path, parent_document_url: parent_document_url)
    end

    def worker
      worker = AssetManagerUpdateAssetWorker
      queue.present? ? worker.set(queue: queue) : worker
    end
  end
end
