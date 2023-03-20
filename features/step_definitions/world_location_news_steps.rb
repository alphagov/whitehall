Given(/^no world locations exist$/) do
  WorldLocation.delete_all
end

When(/^I visit the world location news page$/) do
  visit admin_world_location_news_index_path
end

When(/^I click the Inactive tab$/) do
  click_link "Inactive", class: "govuk-tabs__tab"
end

Then(/^I should see the "([^"]*)" message$/) do |message|
  expect(page).to have_selector("p", text: "#{message}.")
end
