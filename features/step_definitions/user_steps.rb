Given /^there is a user called "([^"]*)"$/ do |name|
  create(:policy_writer, name: name)
end

Given /^there is a user called "([^"]*)" with email address "([^"]*)"$/ do |name, email|
  @user = create(:policy_writer, name: name, email: email)
end

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

When /^I set the role for "([^"]*)" to departmental editor$/ do |name|
  begin_editing_user_details(name)
  check "Departmental editor"
  click_button "Save"
end

When /^I visit the admin author page for "([^"]*)"$/ do |name|
  user = User.find_by_name(name)
  visit admin_author_path(user)
end

Then /^I should see my organisation is "([^"]*)"$/ do |organisation|
  visit admin_user_path
  assert page.has_css?(".user .organisation", text: organisation)
end

Then /^I should see that I am logged in as a "([^"]*)"$/ do |role|
  visit admin_user_path
  within "#session" do
    click_link "#user_settings"
  end
  assert page.has_css?(".user .settings .role", text: role)
end

Then /^I should see my email address is "([^"]*)"$/ do |email_address|
  visit admin_user_path
  assert page.has_css?(".user .email", text: email_address)
end

Then /^I should see an email address "([^"]*)"$/ do |email_address|
  assert page.has_css?(".email", text: email_address)
end

Then /^I should see that I am a departmental editor$/ do
  visit admin_user_path
  assert page.has_css?(".role", "Departmental Editor")
end
