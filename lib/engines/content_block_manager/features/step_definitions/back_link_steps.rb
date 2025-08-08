Then("I should see a back link to the document page") do
  expect(page).to have_link(
    "Back",
    href: content_block_manager.content_block_manager_content_block_document_path(@content_block.document),
  )
end

Then(/^I should see a back link to the "([^"]*)" step$/) do |step|
  @content_block ||= ContentBlockManager::ContentBlock::Edition.last
  link = if step == "edit"
           content_block_manager.new_content_block_manager_content_block_document_edition_path(@content_block.document)
         else
           content_block_manager.content_block_manager_content_block_workflow_path(
             @content_block.document.editions.last,
             step:,
           )
         end
  expect(page).to have_link("Back", href: link)
end
