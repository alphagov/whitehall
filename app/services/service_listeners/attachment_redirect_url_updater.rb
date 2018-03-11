module ServiceListeners
  class AttachmentRedirectUrlUpdater
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper

    attr_reader :attachment_data, :queue

    def initialize(attachment_data, queue: nil)
      @attachment_data = attachment_data
      @queue = queue
    end

    def update!
      return unless attachment_data.present?
      visibility = visibility_for(attachment_data)
      redirect_url = nil
      if !visibility.visible? && (edition = visibility.unpublished_edition)
        redirect_url = edition.unpublishing.document_url
      end
      enqueue_job(attachment_data.file, redirect_url)
      if attachment_data.pdf?
        enqueue_job(attachment_data.file.thumbnail, redirect_url)
      end
    end

  private

    def visibility_for(attachment_data)
      AttachmentVisibility.new(attachment_data, _anonymous_user = nil)
    end

    def enqueue_job(uploader, redirect_url)
      legacy_url_path = uploader.asset_manager_path
      worker.perform_async(legacy_url_path, redirect_url: redirect_url)
    end

    def worker
      worker = AssetManagerUpdateAssetWorker
      queue.present? ? worker.set(queue: queue) : worker
    end
  end
end
