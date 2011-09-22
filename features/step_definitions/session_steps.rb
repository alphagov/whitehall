Given /^I am logged in as "([^"]*)"$/ do |name|
  Given "I visit the login page"
  And %{I login as "#{name}"}
end

Given /^I visit the login page$/ do
  visit login_path
end

Given /^I login as "([^"]*)"$/ do |name|
  fill_in 'Your name', :with => name
  click_button 'Login'
end

Then /^I should be given the opportunity to login$/ do
  assert page.has_css?("form[action='#{session_path}']")
end