Given /^I am (?:a|an) (writer|editor|admin)(?: called "([^"]*)")?$/ do |role, name|
  user = case role
  when "writer"
    create(:policy_writer, name: (name || "Wally Writer"))
  when "editor"
    create(:departmental_editor, name: (name || "Eddie Editor"))
  when "admin"
    create(:user)
  end
  login_as user
end

Given /^I am a writer in the organisation "([^"]*)"$/ do |organisation|
  organisation = Organisation.find_or_create_by_name(organisation)
  user = create(:policy_writer, organisation: organisation)
  login_as user
end

Given /^I logout$/ do
  log_out
end

Given /^I try to access a page that requires authentication$/ do
  draft_policy = create(:draft_policy)
  @path_requiring_authentication = admin_document_path(draft_policy)
  visit @path_requiring_authentication
end

When /^I login as a writer$/ do
  login_as create(:policy_writer)
end

Then /^I should be given the opportunity to login$/ do
  assert page.has_css?("form[action='#{session_path}']")
end

Then /^I should see that I am not logged in$/ do
  assert page.has_no_css?("#session .current_user_name")
end

Then /^I should be asked to login$/ do
  assert page.has_css?("form[action='#{session_path}']")
end

Then /^I should be taken to my original destination$/ do
  assert_current_url @path_requiring_authentication
end
