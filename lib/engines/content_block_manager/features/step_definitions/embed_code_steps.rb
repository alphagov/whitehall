When("I click to copy the embed code") do
  find("a", text: "Copy code").click
  has_text?("Code copied")
  @embed_code = @content_block.document.embed_code
end

When("I click to copy the embed code for the content block {string}") do |content_block_name|
  within(".govuk-summary-card", text: content_block_name) do
    find("a", text: "Copy code").click
    has_text?("Code copied")
    edition = ContentBlockManager::ContentBlock::Edition.find_by(title: content_block_name)
    @embed_code = edition.document.embed_code
  end
end

Then("the embed code should be copied to my clipboard") do
  page.driver.browser.execute_cdp("Browser.grantPermissions", origin: page.server_url, permissions: %w[clipboardReadWrite])
  clip_text = page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")
  expect(clip_text).to eq(@embed_code)
end
