When(/^I visit the admin dashboard$/) do
  visit admin_root_path
end

Then(/^I should see the draft document "([^"]*)"$/) do |title|
  edition = Edition.find_by!(title: title).latest_edition
  assert_selector ".draft-documents #{record_css_selector(edition)}"
end

Then(/^I should see the force published document "([^"]*)"$/) do |title|
  edition = Edition.find_by!(title: title).latest_edition
  assert_selector ".force-published-documents #{record_css_selector(edition)}"
end

Then(/^I should see a link to the content data app$/) do
  link = find_link('Content Data', href: 'https://content-data.test.gov.uk/content')
  assert_equal 'external-link-clicked', link['data-track-category']
  assert_equal 'https://content-data.test.gov.uk/content', link['data-track-action']
  assert_equal 'Content Data', link['data-track-label']
end
