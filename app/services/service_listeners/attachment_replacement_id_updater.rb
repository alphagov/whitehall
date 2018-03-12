module ServiceListeners
  class AttachmentReplacementIdUpdater
    attr_reader :attachment_data

    def initialize(attachment_data)
      @attachment_data = attachment_data
    end

    def update!
      return unless attachment_data.present?

      worker.perform_async(attachment_data.id)
    end

  private

    def worker
      AssetManagerAttachmentReplacementIdUpdateWorker
    end
  end
end
