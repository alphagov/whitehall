Given /^there is a user called "([^"]*)"$/ do |name|
  @user = create(:policy_writer, name: name)
end

Given /^there is a user called "([^"]*)" with email address "([^"]*)"$/ do |name, email|
  @user = create(:policy_writer, name: name, email: email)
end

When /^I set the email address for "([^"]*)" to "([^"]*)"$/ do |name, email_address|
  begin_editing_user_details(name)
  fill_in "Email", with: email_address
  click_button "Save"
end

When /^I view my own user record$/ do
  visit admin_user_path(@user)
end

Then /^I can see my user details/ do
  assert page.has_css?(".user .name", text: @user.name)
  assert page.has_css?(".user .email", text: %r{#{@user.email}})
end

Then /^I cannot change my user details/ do
  assert page.has_no_css?("a[href='#{edit_admin_user_path(@user)}']")
  visit edit_admin_user_path(@user)
  assert page.has_no_css?("form")
end

When /^I visit the admin author page for "([^"]*)"$/ do |name|
  user = User.find_by_name(name)
  visit admin_author_path(user)
end

Then /^I should see that I am logged in as a "([^"]*)"$/ do |role|
  visit admin_user_path(@user)
  click_link "#user_settings"
  assert page.has_css?(".user .settings .role", text: role)
end

Then /^I should see an email address "([^"]*)"$/ do |email_address|
  assert page.has_css?(".email", text: email_address)
end

When /^I visit the user list in the admin section$/ do
  visit admin_users_path
end

Then /^I should see "([^"]*)" in the user list$/ do |name|
  assert page.has_content?(name)
end

When /^I set the organisation for "([^"]*)" to "([^"]*)"$/ do |user_name, organisation_name|
  visit edit_admin_user_path(User.find_by_name(user_name))
  select organisation_name, from: 'Organisation'
  click_on "Save"
end

Then /^the organisation for "([^"]*)" is "([^"]*)"$/ do |user_name, organisation_name|
  assert page.has_css?(".user .name", text: user_name)
  assert page.has_css?(".user .organisation", text: organisation_name)
end
