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

      worker.perform(attachment_data.id, queue)
    end

  private

    def worker
      worker = AssetManagerAttachmentReplacementIdUpdateWorker.new
      queue.present? ? worker.set(queue: queue) : worker
    end
  end
end
