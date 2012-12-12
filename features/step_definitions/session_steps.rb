Given /^I am (?:a|an) (writer|editor|admin|GDS editor|importer)(?: called "([^"]*)")?$/ do |role, name|
  @user = case role
  when "writer"
    create(:policy_writer, name: (name || "Wally Writer"))
  when "editor"
    create(:departmental_editor, name: (name || "Eddie Editor"))
  when "admin"
    create(:user)
  when "GDS editor"
    create(:gds_editor)
  when 'importer'
    create(:importer)
  end
  login_as @user
end

Given /^I am (?:an?) (writer|editor) in the organisation "([^"]*)"$/ do |role, organisation|
  organisation = Organisation.find_or_create_by_name(organisation)
  @user = case role
  when "writer"
    create(:policy_writer, name: "Wally Writer", organisation: organisation)
  when "editor"
    create(:departmental_editor, name: "Eddie Editor", organisation: organisation)
  end
  login_as @user
end

Given /^I am a visitor$/ do
  User.stubs(:first).returns(nil)
end

Around("@use_real_sso") do |scenario, block|
  current_sso_env = ENV['GDS_SSO_MOCK_INVALID']
  ENV['GDS_SSO_MOCK_INVALID'] = "1"
  block.call
  ENV['GDS_SSO_MOCK_INVALID'] = current_sso_env
end
