When /^I publish a publication with an HTML version$/ do
  begin_drafting_publication("Beard figures 2012")

  fill_in "HTML version title", with: 'HTML version title'
  fill_in "HTML version text", with: 'HTML version text'
  click_button "Save"
  click_button "Force Publish"
end

When /^I begin drafting a new publication with an HTML version$/ do
  begin_drafting_publication("Beard figures 2012")
  fill_in "HTML version title", with: 'HTML version title'
  fill_in "HTML version text", with: 'HTML version text'
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

When /^I reference the image from the HTML version$/ do
  fill_in "HTML version text", with: "\n\n!!1\n\nRest of publication"
end

Then /^the HTML version of the published publication should show the referenced image$/ do
  click_on "Save"
  click_on "Force Publish"

  visit public_document_path(Publication.last)
  click_on HtmlVersion.last.title

  assert page.has_css?('img[src*=minister-of-funk]')
end
