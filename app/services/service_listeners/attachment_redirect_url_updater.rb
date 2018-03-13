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
      AssetManagerAttachmentRedirectUrlUpdateWorker.new.perform(attachment_data.id)
    end
  end
end
