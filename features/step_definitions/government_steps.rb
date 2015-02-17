When(/^I create a government called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  create_government(name: government_name, start_date: start_date, end_date: end_date)
end

Then(/^there should be a government called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  check_for_government(name: government_name, start_date: start_date, end_date: end_date)
end

Given(/^a government exists called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  FactoryGirl.create(:government, name: government_name, start_date: start_date, end_date: end_date)
end

When(/^I edit the government called "(.*?)" to have dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  edit_government(name: government_name, attributes: {
    start_date: start_date,
    end_date: end_date
  })
end
