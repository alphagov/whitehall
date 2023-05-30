When(/^I visit the admin dashboard$/) do
  visit admin_root_path
end

Then(/^I should see the draft document "([^"]*)"$/) do |title|
  expect(all(".govuk-table")[0].all(".govuk-table__cell")[0].text).to eq title
end

Then(/^I should see the force published document "([^"]*)"$/) do |title|
  expect(all(".govuk-table")[1].all(".govuk-table__cell")[0].text).to eq title
end

Then(/^I should see a link to the content data app$/) do
  expect(find_link("Content Data", href: "https://content-data.test.gov.uk/content")).not_to be_nil
end
