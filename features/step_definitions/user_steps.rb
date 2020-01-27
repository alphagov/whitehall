Given(/^there is a user called "([^"]*)"$/) do |name|
  @user = create(:writer, name: name)
end

Given(/^there is a user called "([^"]*)" with email address "([^"]*)"$/) do |name, email|
  @user = create(:writer, name: name, email: email)
end

When(/^I view my own user record$/) do
  visit admin_user_path(@user)
end

Then(/^I can see my user details/) do
  assert_selector ".user .name", text: @user.name
  assert_selector ".user .email", text: %r{#{@user.email}}
end

Then(/^I cannot change my user details/) do
  assert_no_selector "a[href='#{edit_admin_user_path(@user)}']"
  visit edit_admin_user_path(@user)
  assert_no_selector "form"
end

When(/^I visit the admin author page for "([^"]*)"$/) do |name|
  user = User.find_by(name: name)
  visit admin_author_path(user)
end

Then(/^I should see that I am logged in as a "([^"]*)"$/) do |role|
  visit admin_user_path(@user)
  click_link "#user_settings"
  assert_selector ".user .settings .role", text: role
end

Then(/^I should see an email address "([^"]*)"$/) do |email_address|
  assert_selector ".email", text: email_address
end

When(/^I visit the user list in the admin section$/) do
  visit admin_users_path
end

Then(/^I should see "([^"]*)" in the user list$/) do |name|
  assert_text name
end
