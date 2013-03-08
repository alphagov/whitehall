Given /^I start editing the speech "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

Given /^"([^"]*)" submitted a speech "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am a writer called "#{author}"}
  visit new_admin_speech_path
  begin_drafting_speech title: title, body: body
  click_button 'Save'
  click_button 'Submit'
end

Given /^a published speech "([^"]*)" by "([^"]*)" on "([^"]*)" at "([^"]*)"$/ do |title, ministerial_role, delivered_on, location|
  role_appointment = MinisterialRole.all.detect { |mr| mr.name == ministerial_role }.current_role_appointment
  create(:published_speech, title: title, role_appointment: role_appointment, delivered_on: Date.parse(delivered_on), location: location)
end

Given /^a published speech exists$/ do
  @speech = create(:published_speech)
end

Given /^a published speech "([^"]*)" with related published policies "([^"]*)" and "([^"]*)"$/ do |speech_title, policy_title_1, policy_title_2|
  policy_1 = create(:published_policy, title: policy_title_1)
  policy_2 = create(:published_policy, title: policy_title_2)
  create(:published_speech, title: speech_title, related_editions: [policy_1, policy_2])
end

Given /^a published speech "([^"]*)" for the organisation "([^"]*)"$/ do |title, organisation|
  organisation = create(:organisation, name: organisation)
  create(:published_speech, title: title, organisations: [organisation])
end

Given /^a published speech "([^"]*)" for the policy "([^"]*)"$/ do |title, policy_name|
  policy = Policy.find_by_title(policy_name) || create(:policy, title: policy_name)
  create(:published_speech, title: title, related_editions: [policy])
end

Given /^(\d+) published speeches for the organisation "([^"]*)"$/ do |count, organisation|
  organisation = create(:organisation, name: organisation)
  count.to_i.times { |i| create(:published_speech, title: "keyword-#{i}", organisations: [organisation]) }
end

When /^I edit the speech "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  speech = Speech.find_by_title!(original_title)
  visit admin_edition_path(speech)
  click_link "Edit"
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I edit the speech changing the title to "([^"]*)"$/ do |new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I visit the list of speeches awaiting review$/ do
  visit admin_editions_path(state: :submitted)
end

When /^I create a new edition of the published speech$/ do
  visit admin_editions_path(state: :published)
  click_link Speech.published.last.title
  click_button 'Create new edition'
end

When /^I draft a new speech "([^"]*)"$/ do |title|
  begin_drafting_speech title: title
  click_button "Save"
end

When /^I visit the speech "([^"]*)"$/ do |title|
  speech = Speech.find_by_title!(title)
  visit public_document_path(speech)
end

When /^I draft a new speech "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_speech title: title
  select first_policy, from: "Related policies"
  select second_policy, from: "Related policies"
  click_button "Save"
end

Then /^I should see that "([^"]*)" is the speech body$/ do |body|
  assert page.has_css?(".document .body", text: body)
end

Then /^the published speech should remain unchanged$/ do
  visit public_document_path(@speech)
  assert page.has_css?('.page_title', text: @speech.title)
  assert page.has_css?('.body', text: @speech.body)
end

Then /^I should see the speech was delivered on "([^"]*)" at "([^"]*)"$/ do |delivered_on, location|
  assert page.has_css?('.delivered-on', text: delivered_on)
  assert page.has_css?('.location', text: location)
end
