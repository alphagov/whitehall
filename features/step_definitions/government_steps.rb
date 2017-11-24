When(/^I create a government called "(.*?)" starting on "(.*?)"$/) do |government_name, start_date|
  create_government(name: government_name, start_date: start_date)
end

When(/^I create a government called "([^"]+)"$/) do |government_name|
  create_government(name: government_name)
end

Then(/^the current government should be "(.*?)"$/) do |government_name|
  check_for_current_government(name: government_name)
end

Then(/^there should be a government called "(.*?)" starting on "(.*?)"$/) do |government_name, start_date|
  check_for_government(name: government_name, start_date: start_date)
end

Then(/^there should be a government called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  check_for_government(name: government_name, start_date: start_date, end_date: end_date)
end

Given(/^a government exists called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  FactoryBot.create(:government, name: government_name, start_date: start_date, end_date: end_date)
end

Given(/^a government exists called "(.*?)" starting on "(.*?)"$/) do |government_name, start_date|
  FactoryBot.create(:government, name: government_name, start_date: start_date)
end

When(/^I edit the government called "(.*?)" to have dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  edit_government(name: government_name, attributes: {
    start_date: start_date,
    end_date: end_date
  })
end

Given(/^there is a current government$/) do
  FactoryBot.create(:current_government)
end

When(/^I close the current government$/) do
  close_government(name: Government.current.name)
end

Then(/^there should be no active ministerial role appointments$/) do
  assert_equal 0, count_active_ministerial_role_appointments
end
