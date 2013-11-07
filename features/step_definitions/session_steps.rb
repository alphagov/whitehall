Given /^I am (?:a|an) (writer|editor|admin|GDS editor|importer|managing editor)(?: called "([^"]*)")?$/ do |role, name|
  @user = case role
  when "writer"
    create(:policy_writer, name: (name || "Wally Writer"))
  when "editor"
    create(:departmental_editor, name: (name || "Eddie Depteditor"))
  when "admin"
    create(:user)
  when "GDS editor"
    create(:gds_editor)
  when 'importer'
    create(:importer)
  when 'managing editor'
    create(:managing_editor)
  end
  login_as @user
end

Given /^I am (?:an?) (writer|editor) in the organisation "([^"]*)"$/ do |role, organisation_name|
  organisation = Organisation.find_by_name(organisation_name) || create(:organisation, name: organisation_name)
  @user = case role
  when "writer"
    create(:policy_writer, name: "Wally Writer", organisation: organisation)
  when "editor"
    create(:departmental_editor, name: "Eddie Depteditor", organisation: organisation)
  end
  login_as @user
end

Given /^I am a visitor$/ do
  User.stubs(:first).returns(nil)
end

When /^I log out$/ do
  log_out
end

Around("@use_real_sso") do |scenario, block|
  current_sso_env = ENV['GDS_SSO_MOCK_INVALID']
  ENV['GDS_SSO_MOCK_INVALID'] = "1"
  block.call
  ENV['GDS_SSO_MOCK_INVALID'] = current_sso_env
end
