Given /^a draft publication called "([^"]*)" exists$/ do |title|
  publication = create(:publication)
  create(:draft_edition, title: title, document: publication)
end

Given /^a submitted publication called "([^"]*)" exists$/ do |title|
  publication = create(:publication)
  create(:submitted_edition, title: title, document: publication)
end

When /^I draft a new publication "([^"]*)"$/ do |title|
  visit admin_editions_path
  click_link "Draft new Publication"
  fill_in "Title", with: title
  fill_in "Policy", with: "Any old iron"
  click_button "Save"
end

When /^I submit the publication "([^"]*)"$/ do |title|
  publication = Edition.find_by_title(title)
  visit admin_editions_path
  within(object_css_selector(publication)) do
    click_link title
  end
  click_link "Edit"
  check "Submit to second set of eyes"
  click_button "Save"
end

When /^I publish the publication "([^"]*)"$/ do |title|
  publication = Edition.find_by_title(title)
  visit admin_editions_path
  click_link "submitted"
  within(object_css_selector(publication)) do
    click_link title
  end
  click_button "Publish"
end

Then /^I should see the publication "([^"]*)" in the list of draft documents$/ do |title|
  visit admin_editions_path
  assert page.has_css?(".edition", text: title)
end

Then /^I should see the publication "([^"]*)" in the list of submitted documents$/ do |title|
  visit submitted_admin_editions_path
  assert page.has_css?(".edition", text: title)
end

Then /^I should see the publication "([^"]*)" in the list of published documents$/ do |title|
  visit published_admin_editions_path
  assert page.has_css?(".edition", text: title)
end

Then /^the publication "([^"]*)" should be visible to the public$/ do |title|
  publication = Edition.find_by_title(title).document
  visit documents_path
  assert page.has_css?(object_css_selector(publication), text: title)
end