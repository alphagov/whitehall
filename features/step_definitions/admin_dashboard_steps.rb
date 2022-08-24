When(/^I visit the admin dashboard$/) do
  visit admin_root_path
end

Then(/^I should see the draft document "([^"]*)"$/) do |title|
  edition = Edition.find_by!(title: title).document.latest_edition
  expect(page).to have_selector(".draft-documents #{record_css_selector(edition)}")
end

Then(/^I should see the force published document "([^"]*)"$/) do |title|
  edition = Edition.find_by!(title: title).document.latest_edition
  expect(page).to have_selector(".force-published-documents #{record_css_selector(edition)}")
end

Then(/^I should see a link to the content data app$/) do
  link = find_link("Content Data", href: "https://content-data.test.gov.uk/content")
  expect("external-link-clicked").to eq(link["data-track-category"])
  expect("https://content-data.test.gov.uk/content").to eq(link["data-track-action"])
  expect("Content Data").to eq(link["data-track-label"])
end
