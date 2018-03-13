module ServiceListeners
  class AttachmentDeleter
    attr_reader :attachment_data

    def initialize(attachment_data)
      @attachment_data = attachment_data
    end

    def delete!
      return unless attachment_data.present?

      AssetManagerAttachmentDeleteWorker.perform_async(attachment_data.id)
    end
  end
end
