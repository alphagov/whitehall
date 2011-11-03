Given /^I am (?:a|an) (writer|editor)(?: called "([^"]*)")?$/ do |role, name|
  visit login_path
  if role == "writer"
    fill_in "name", with: name || "Wally Writer"
  else
    fill_in "name", with: name || "Eddie Editor"
    check "I am a departmental editor"
  end
  click_button "Login"
end

Given /^I am a writer in the organisation "([^"]*)"$/ do |organisation|
  visit login_path
  fill_in "name", with: "Wally Writer"
  select organisation, from: "Organisation"
  click_button "Login"
end

Given /^I logout$/ do
  click_button "Logout"
end

Then /^I should see that I am logged in as a ([^"]*)$/ do |role|
  assert page.has_css?("#session .role", text: role)
end

Then /^I should be given the opportunity to login$/ do
  assert page.has_css?("form[action='#{session_path}']")
end

Then /^I should see that I am logged in as "([^"]*)"$/ do |name|
  assert page.has_css?("#session .current_user_name", text: name)
end

Then /^I should see that I am not logged in$/ do
  assert page.has_no_css?("#session .current_user_name")
end