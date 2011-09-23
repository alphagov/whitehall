Given /^I am logged in as "([^"]*)"$/ do |name|
  Given "I visit the login page"
  And %{I login as "#{name}"}
end

Given /^I am logged in as a departmental editor called "([^"]*)"$/ do |name|
  Given "I visit the login page"
  check "I am a departmental editor"
  And %{I login as "#{name}"}
end

Given /^I visit the login page$/ do
  visit login_path
end

Given /^I login as "([^"]*)"$/ do |name|
  fill_in 'Your name', with: name
  click_button 'Login'
end

Then /^I should be given the opportunity to login$/ do
  assert page.has_css?("form[action='#{session_path}']")
end

Then /^I should not see a link to login$/ do
  assert page.has_no_css?(".session a[href='#{login_path}']")
end

Then /^I should see that I am logged in as "([^"]*)"$/ do |name|
  assert page.has_css?('.session .current_user_name', :text => name)
end

Given /^I logout$/ do
  click_button "Logout"
end

Then /^I should see that I am not logged in$/ do
  assert page.has_no_css?('.session .current_user_name')
end