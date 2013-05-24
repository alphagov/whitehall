When /^I visit the admin dashboard$/ do
  visit admin_root_path
end

Then /^I should see the draft document "([^"]*)"$/ do |title|
  edition = Edition.find_by_title!(title).latest_edition
  assert has_css?(".draft-documents #{record_css_selector(edition)}")
end

Then /^I should see the force published document "([^"]*)"$/ do |title|
  edition = Edition.find_by_title!(title).latest_edition
  assert has_css?(".force-published-documents #{record_css_selector(edition)}")
end
