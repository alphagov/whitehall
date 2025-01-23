When("I access the create object page") do
  visit content_block_manager.new_content_block_manager_content_block_edition_path
end

When("I visit the page for the content block") do
  visit content_block_manager.content_block_manager_content_block_edition_path(@content_block)
end

When("I visit the Content Block Manager home page") do
  visit content_block_manager.content_block_manager_root_path
end

When("I visit a block's content ID endpoint") do
  block = ContentBlockManager::ContentBlock::Document.last
  visit content_block_manager.content_block_manager_content_block_content_id_path(block.content_id)
end

When("I revisit the edit page") do
  @content_block = @content_block.document.latest_edition
  visit_edit_page
end
