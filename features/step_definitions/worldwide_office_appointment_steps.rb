
When /^I create a new "([^"]*)" worldwide office appointment and assign it to "([^"]*)"$/ do |appointment_name, person_name|
  office = WorldwideOffice.last
  visit admin_worldwide_office_path(office)
  click_link 'Appointments'
  click_link 'Add'
  fill_in 'Job title', with: appointment_name
  select person_name, from: 'Person'
  click_button 'Save'
end
