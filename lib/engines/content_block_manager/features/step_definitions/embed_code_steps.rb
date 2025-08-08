When("I click to copy the embed code for the pension {string}, rate {string} and field {string}") do |pension_title, rate_name, field_name|
  within(".govuk-summary-list__row", text: field_name.humanize) do
    find("a", text: "Copy code").click
    has_text?("Code copied")
    edition = ContentBlockManager::ContentBlock::Edition.find_by(title: pension_title)
    @embed_code = edition.document.embed_code_for_field("rates/#{rate_name.parameterize.presence}/#{field_name}")
  end
end

Then("the embed code should be copied to my clipboard") do
  Capybara.current_session.driver.with_playwright_page do |page|
    page.context.grant_permissions(%w[clipboard-read])
  end
  clip_text = page.evaluate_async_script("navigator.clipboard.readText().then(arguments[0])")
  expect(clip_text).to eq(@embed_code)
end

Then("the embed code for the content block {string}, rate {string} and field {string} should be visible") do |pension_title, rate_name, field_name|
  edition = ContentBlockManager::ContentBlock::Edition.find_by(title: pension_title)
  embed_code = edition.document.embed_code_for_field("rates/#{rate_name.parameterize.presence}/#{field_name}")
  expect(page).to have_content(embed_code)
end
