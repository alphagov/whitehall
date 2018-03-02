module ServiceListeners
  class AttachmentReplacementIdUpdater
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper

    attr_reader :attachment_data, :queue

    def initialize(attachment_data, queue: nil)
      @attachment_data = attachment_data
      @queue = queue
    end

    def update!
      return unless attachment_data.present?

      return unless attachment_data.replaced_by.present?
      replacement = attachment_data.replaced_by

      enqueue_job(attachment_data.file, replacement.file)
      if attachment_data.pdf?
        if replacement.pdf?
          enqueue_job(attachment_data.file.thumbnail, replacement.file.thumbnail)
        else
          enqueue_job(attachment_data.file.thumbnail, replacement.file)
        end
      end
    end

  private

    def enqueue_job(uploader, replacement_uploader)
      legacy_url_path = uploader.asset_manager_path
      replacement_legacy_url_path = replacement_uploader.asset_manager_path
      worker.perform_async(legacy_url_path, replacement_legacy_url_path: replacement_legacy_url_path)
    end

    def worker
      worker = AssetManagerUpdateAssetWorker
      queue.present? ? worker.set(queue: queue) : worker
    end
  end
end
