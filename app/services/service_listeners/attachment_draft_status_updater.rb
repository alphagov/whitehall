module ServiceListeners
  class AttachmentDraftStatusUpdater
    attr_reader :attachment_data, :queue

    def initialize(attachment_data, queue: nil)
      @attachment_data = attachment_data
      @queue = queue
    end

    def update!
      return unless attachment_data.present?
      visibility = visibility_for(attachment_data)
      draft = !(visibility.visible? || visibility.unpublished_edition)
      enqueue_job(attachment_data.file, draft)
      if attachment_data.pdf?
        enqueue_job(attachment_data.file.thumbnail, draft)
      end
    end

  private

    def visibility_for(attachment_data)
      AttachmentVisibility.new(attachment_data, _anonymous_user = nil)
    end

    def enqueue_job(uploader, draft)
      legacy_url_path = uploader.asset_manager_path
      worker.perform_async(legacy_url_path, draft: draft)
    end

    def worker
      worker = AssetManagerUpdateAssetWorker
      queue.present? ? worker.set(queue: queue) : worker
    end
  end
end
