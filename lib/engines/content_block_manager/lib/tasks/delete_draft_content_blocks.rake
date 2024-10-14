namespace :content_block_manager do
  desc "Delete draft Content Block Editions and any orphaned Content Block Documents"
  task delete_draft_content_blocks: :environment do
    draft_content_editions = ContentBlockManager::ContentBlock::Edition.where(state: "draft")
    puts "Starting to delete #{draft_content_editions.count} draft Content Blocks in rake task delete_draft_content_blocks"
    draft_content_editions.each do |draft_content_edition|
      puts "Deleting draft Content Block Edition #{draft_content_edition.id}"
      ContentBlockManager::DeleteEditionService.new.call(draft_content_edition)
    end
    puts "Finished deleting draft Content Blocks in rake task delete_draft_content_blocks"
  end
end
