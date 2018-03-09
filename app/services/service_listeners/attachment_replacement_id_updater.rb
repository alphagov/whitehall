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

      legacy_url_path = attachment_data.file.asset_manager_path
      replacement_legacy_url_path = replacement.file.asset_manager_path
      worker = AssetManagerUpdateAssetWorker
      worker.set(queue: queue) if queue.present?
      worker.perform_async(legacy_url_path, replacement_legacy_url_path: replacement_legacy_url_path)
      if attachment_data.pdf?
        if replacement.pdf?
          legacy_url_path = attachment_data.file.thumbnail.asset_manager_path
          replacement_legacy_url_path = replacement.file.thumbnail.asset_manager_path
          worker = AssetManagerUpdateAssetWorker
          worker.set(queue: queue) if queue.present?
          worker.perform_async(legacy_url_path, replacement_legacy_url_path: replacement_legacy_url_path)
        else
          legacy_url_path = attachment_data.file.thumbnail.asset_manager_path
          replacement_legacy_url_path = replacement.file.asset_manager_path
          worker = AssetManagerUpdateAssetWorker
          worker.set(queue: queue) if queue.present?
          worker.perform_async(legacy_url_path, replacement_legacy_url_path: replacement_legacy_url_path)
        end
      end
    end
  end
end
