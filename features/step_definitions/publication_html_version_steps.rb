When /^I add an HTML version of the publication$/ do
  fill_in "HTML version title", with: 'HTML version title'
  fill_in "HTML version text", with: 'HTML version text'
  click_button "Save"
  click_button "Force Publish"
end

Then /^the HTML version should be visible on the public page$/ do
  visit public_document_path(Publication.last)
  assert page.has_css?(".publication .attachment .type abbr", text: "HTML")
end

Then /^citizens should be able to view the HTML version$/ do
  click_on HtmlVersion.last.title
end

Then /^the HTML version should be styled with the organisation logo$/ do
  assert page.has_css?('.organisation-logo')
end

Then /^the HTML version should link back to the publication record page$/ do
  assert page.has_css?("a[href*='#{public_document_path(Publication.last)}']")
end
