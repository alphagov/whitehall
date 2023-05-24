When(/^I create a government called "(.*?)" starting on "(.*?)"$/) do |government_name, start_date|
  create_government(name: government_name, start_date:)
end

When(/^I create a government called "([^"]+)"$/) do |government_name|
  create_government(name: government_name)
end

Then(/^the current government should be "(.*?)"$/) do |government_name|
  check_for_current_government(name: government_name)
end

Then(/^there should be a government called "(.*?)" starting on "(.*?)"$/) do |government_name, start_date|
  check_for_government(name: government_name, start_date:)
end

Then(/^there should be a government called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  check_for_government(name: government_name, start_date:, end_date:)
end

Given(/^a government exists called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  FactoryBot.create(:government, name: government_name, start_date:, end_date:)
end

When(/^I edit the government called "(.*?)" to have dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  edit_government(
    name: government_name,
    attributes: {
      start_date:,
      end_date:,
    },
  )
end

Given(/^there is a current government$/) do
  FactoryBot.create(:current_government)
end

Given(/^two cabinet ministers "([^"]*)" and "([^"]*)"$/) do |person1, person2|
  create(:role_appointment, person: create(:person, forename: person1), role: create(:ministerial_role, cabinet_member: true))
  create(:role_appointment, person: create(:person, forename: person2), role: create(:ministerial_role, cabinet_member: true))
end

Given(/^"([^"]*)" is the "([^"]*)" for the "([^"]*)"$/) do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 2.years.ago)
end

When(/^I close the current government$/) do
  close_government(name: Government.current.name)
end

Then(/^there should be no active ministerial role appointments$/) do
  expect(0).to eq(count_active_ministerial_role_appointments)
end

Given(/^that there no governments available to view$/) do
  Government.delete_all
end

When(/^I visit the governments page$/) do
  visit admin_governments_path
end

Then(/^I should see no governments message$/) do
  expect(page).to have_selector("p", text: "No governments have been created.")
end
