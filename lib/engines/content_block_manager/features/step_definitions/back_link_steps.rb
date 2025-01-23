Then("I should see a back link to the select schema page") do
  expect(page).to have_link("Back", href: content_block_manager.new_content_block_manager_content_block_document_path)
end

Then("I should see a back link to the document page") do
  expect(page).to have_link(
    "Back",
    href: content_block_manager.content_block_manager_content_block_document_path(@content_block.document),
  )
end

Then("I should see a back link to the show page") do
  match_data = URI.parse(page.current_url).path.match(%r{content-block-editions/(\d+)/edit$})
  id = match_data[1] unless match_data.nil?
  expect(id).not_to be_nil, "Could not find an existing content block edition ID in the URL"
  expect(page).to have_link("Back", href: content_block_manager.content_block_manager_content_block_edition_path(id))
end

Then(/^I should see a back link to the "([^"]*)" step$/) do |step|
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

Then("I should see a back link to the document list page") do
  expect(page).to have_link("Back", href: content_block_manager.content_block_manager_content_block_documents_path)
end
