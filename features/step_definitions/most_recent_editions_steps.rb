When(/^someone else creates a new edition of the published document "([^"]*)"$/) do |title|
  random_editor = create(:departmental_editor)
  current = Edition.find_by(title: title).document.latest_edition
  current.create_draft(random_editor)
end

When(/^someone else creates a new edition of the published document "([^"]*)" and limits access to members of "([^"]+)"$/) do |title, organisation_name|
  org = Organisation.find_by(name: organisation_name) || create(:organisation, name: organisation_name)
  random_editor = create(:departmental_editor)
  current = Edition.find_by(title: title).document.latest_edition
  new_draft = current.create_draft(random_editor)
  new_draft.organisations << org
  new_draft.access_limited = true
  new_draft.change_note = "Limited to #{org.name}"
  new_draft.save!
end

When(/^I view the old edition of document "([^"]*)"$/) do |title|
  oldest = Edition.find_by(title: title).document.editions.first
  visit admin_edition_path(oldest)
end

Then(/^I can click through to the most recent version of document "([^"]*)"$/) do |title|
  click_on "Go to draft"
  expect(page).to have_current_path(admin_edition_path(Edition.find_by(title: title).document.latest_edition))
end

Then(/^I cannot click through to the most recent version of document "([^"]*)"$/) do |_title|
  expect(page).to have_selector(".alert.access-limited-latest-edition")
  expect(page).to_not have_content("Go to draft")
end
