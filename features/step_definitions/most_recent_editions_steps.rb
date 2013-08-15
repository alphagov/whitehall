When /^someone else creates a new edition of the published document "([^"]*)"$/ do |title|
  random_editor = create(:departmental_editor)
  current = Edition.find_by_title(title).latest_edition
  current.create_draft(random_editor)
end

When /^someone else creates a new edition of the published document "([^"]*)" and limits access to members of "([^"]+)"$/ do |title, organisation_name|
  org = Organisation.find_by_name(organisation_name) || create(:organisation, name: organisation_name)
  random_editor = create(:departmental_editor)
  current = Edition.find_by_title(title).latest_edition
  new_draft = current.create_draft(random_editor)
  new_draft.organisations << org
  new_draft.access_limited = true
  new_draft.change_note = 'Limited to '+org.name
  new_draft.save!
end

When /^I view the old edition of document "([^"]*)"$/ do |title|
  newest = Edition.find_by_title(title).latest_edition
  oldest = newest.document.editions.order(:id).first
  visit admin_edition_path(oldest)
end

Then /^I can click through to the most recent version of document "([^"]*)"$/ do |title|
  click_on 'Go to draft'
  assert_equal admin_edition_path(Edition.find_by_title(title).latest_edition), current_path
end

Then /^I cannot click through to the most recent version of document "([^"]*)"$/ do |arg1|
  assert page.has_css?('.alert.access-limited-latest-edition')
  assert page.has_no_content?('Go to draft')
end

