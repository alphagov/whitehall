require "sidekiq/api"

module ContentBlockManager
  class DeleteDraftContentBlocksWorker < WorkerBase
    sidekiq_options queue: :content_block_publishing

    def perform
      draft_content_editions = ContentBlockManager::ContentBlock::Edition.draft.where("created_at < ?", 60.days.ago).limit(100)
      puts "Starting to delete #{draft_content_editions.count} draft Content Blocks"
      draft_content_editions.each do |draft_content_edition|
        puts "Deleting draft Content Block Edition #{draft_content_edition.id}"
        ContentBlockManager::DeleteEditionService.new.call(draft_content_edition)
      end
      puts "Finished deleting draft Content Blocks"
    end
  end
end
