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
