require "sidekiq/api"

module ContentBlockManager
  class DeleteDraftContentBlocksWorker < WorkerBase
    sidekiq_options queue: :content_block_publishing

    def perform
      draft_content_editions = ContentBlockManager::ContentBlock::Edition.draft.where("created_at < ?", 60.days.ago).limit(100)
      logger.info("[delete-draft-content-blocks-debug] Starting to delete #{draft_content_editions.count} draft Content Blocks")
      draft_content_editions.each do |draft_content_edition|
        logger.info("[delete-draft-content-blocks-debug] Deleting draft Content Block Edition #{draft_content_edition.id}")
        ContentBlockManager::DeleteEditionService.new.call(draft_content_edition)
      end
      logger.info("[delete-draft-content-blocks-debug] Finished deleting draft Content Blocks")
    end
  end
end
