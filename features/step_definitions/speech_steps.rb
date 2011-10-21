Given /^I start editing the speech "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

Given /^"([^"]*)" submitted a speech "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am a writer called "#{author}"}
  And %{I visit the new speech page}
  And %{I write and save a speech "#{title}" with body "#{body}"}
  And %{I submit the speech for the second set of eyes}
end

Given /^I visit the new speech page$/ do
  visit new_admin_speech_path
end

Given /^I write and save a speech "([^"]*)" with body "([^"]*)"$/ do |title, body|
  When %{I write a speech "#{title}" with body "#{body}"}
  click_button 'Save'
end

Given /^I write a speech "([^"]*)" with body "([^"]*)"$/ do |title, body|
  fill_in 'Title', with: title
  fill_in 'Body', with: body
end

Given /^I submit the speech for the second set of eyes$/ do
  click_button 'Submit to 2nd pair of eyes'
end

Given /^a published speech exists$/ do
  @speech = create(:published_speech)
end


When /^I edit the speech "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  speech = Speech.find_by_title(original_title)
  visit admin_document_path(speech)
  click_link "Edit"
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I edit the speech changing the title to "([^"]*)"$/ do |new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I visit the list of speeches awaiting review$/ do
  visit submitted_admin_documents_path
end

When /^I create a new edition of the published speech$/ do
  visit published_admin_documents_path
  click_link Speech.published.last.title
  click_button 'Create new draft'
end



Then /^I should see that "([^"]*)" is the speech author$/ do |name|
  assert page.has_css?(".document_view .author", text: name)
end

Then /^I should see that "([^"]*)" is the speech body$/ do |body|
  assert page.has_css?(".document_view .body", text: body)
end

Then /^the published speech should remain unchanged$/ do
  visit document_path(@speech.document_identity)
  assert page.has_css?('.document_view .title', text: @speech.title)
  assert page.has_css?('.document_view .body', text: @speech.body)
end
