module ServiceListeners
  class AttachmentRedirectUrlUpdater
    include Rails.application.routes.url_helpers
    include PublicDocumentRoutesHelper

    attr_reader :attachment_data

    def initialize(attachment_data)
      @attachment_data = attachment_data
    end

    def update!
      return unless attachment_data.present?
      redirect_url = nil
      if attachment_data.unpublished?
        redirect_url = attachment_data.unpublished_edition.unpublishing.document_url
      end
      enqueue_job(attachment_data.file, redirect_url)
      if attachment_data.pdf?
        enqueue_job(attachment_data.file.thumbnail, redirect_url)
      end
    end

  private

    def enqueue_job(uploader, redirect_url)
      legacy_url_path = uploader.asset_manager_path
      worker.perform_async(legacy_url_path, redirect_url: redirect_url)
    end

    def worker
      AssetManagerUpdateAssetWorker
    end
  end
end
