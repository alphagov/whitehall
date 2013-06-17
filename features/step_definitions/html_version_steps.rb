def fill_in_html_version_and_save
  fill_in "HTML version title", with: 'HTML version title'
  fill_in "HTML version text", with: 'HTML version text'
  click_button "Save"
  publish(force: true)
end

When /^I publish a publication with an HTML version$/ do
  begin_drafting_publication("Beard figures 2012")
  fill_in_html_version_and_save
end

When /^I publish a consultation with an HTML version$/ do
  begin_drafting_consultation(title: "Beard consultation 2012")
  select_date 1.day.ago.to_s, from: "Opening Date"
  select_date 6.days.from_now.to_s, from: "Closing Date"
  fill_in_html_version_and_save
end

When /^I begin drafting a new publication with an HTML version$/ do
  begin_drafting_publication("Beard figures 2012")
  fill_in "HTML version title", with: 'HTML version title'
  fill_in "HTML version text", with: 'HTML version text'
end

Then /^the HTML version of the (publication|consultation) should be visible on the public page$/ do |edition_type|
  edition = Edition.last
  visit public_document_path(edition)
  assert page.has_css?(".#{edition_type} .attachment .type abbr", text: "HTML")
end

Then /^citizens should be able to view the HTML version$/ do
  click_on HtmlVersion.last.title
end

Then /^the HTML version should be styled with the organisation logo$/ do
  assert page.has_css?('.organisation-logo')
end

Then /^the HTML version should link back to the (publication|consultation) record page$/ do |edition_type|
  assert page.has_css?("a[href*='#{public_document_path(Edition.last)}']")
end

When /^I reference the image from the HTML version$/ do
  fill_in "HTML version text", with: "\n\n!!1\n\nRest of publication"
end

Then /^the HTML version of the published publication should show the referenced image$/ do
  click_on "Save"
  publish(force: true)

  visit public_document_path(Publication.last)
  click_on HtmlVersion.last.title

  assert page.has_css?('img[src*=minister-of-funk]')
end
