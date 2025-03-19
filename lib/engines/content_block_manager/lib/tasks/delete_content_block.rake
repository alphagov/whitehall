namespace :content_block_manager do
  desc "Delete content block"
  task :delete_content_block, [:content_id] => :environment do |_t, args|
    content_id = args[:content_id]
    content_block_document = ContentBlockManager::ContentBlock::Document.find_by(content_id:)

    abort("A content block with the content ID `#{content_id}` cannot be found") unless content_block_document

    @host_content_items = ContentBlockManager::HostContentItem.for_document(content_block_document)

    abort("Content block `#{content_id}` cannot be deleted because it has host content. Try removing the dependencies and trying again") unless @host_content_items.items.count.zero?

    Services.publishing_api.unpublish(
      content_id,
      type: "vanish",
      locale: "en",
      discard_drafts: true,
    )

    content_block_document.soft_delete

    puts "Content block `#{content_id}` has been deleted."
  end
end
