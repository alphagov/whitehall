When(/^I create a government called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  create_government(name: government_name, start_date: start_date, end_date: end_date)
end

Then(/^there should be a government called "(.*?)" between dates "(.*?)" and "(.*?)"$/) do |government_name, start_date, end_date|
  check_for_government(name: government_name, start_date: start_date, end_date: end_date)
end
