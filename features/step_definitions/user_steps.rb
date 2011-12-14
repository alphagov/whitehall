When /^I set the email address for "([^"]*)" to "([^"]*)"$/ do |name, email_address|
  begin_editing_user_details(name)
  fill_in "Email", with: email_address
  click_button "Save"
end

When /^I set the organisation for "([^"]*)" to "([^"]*)"$/ do |name, organisation|
  begin_editing_user_details(name)
  select organisation, from: "Organisation"
  click_button "Save"
end

Then /^I should see my organisation is "([^"]*)"$/ do |organisation|
  visit admin_user_path
  assert page.has_css?(".user .organisation", text: organisation)
end

Then /^I should see that I am logged in as a "([^"]*)"$/ do |role|
  within "#session" do
    click_link "#user_settings"
  end
  assert page.has_css?(".user .settings .role", text: role)
end

Then /^I should see that I am logged in as "([^"]*)"$/ do |name|
  assert page.has_css?("#session .current_user_name", text: name)
end

Then /^I should see my email address is "([^"]*)"$/ do |email_address|
  visit admin_user_path
  assert page.has_css?(".user .email", text: email_address)
end