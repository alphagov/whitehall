And(/^I edit the topical event "([^"]*)" adding the social media service of "([^"]*)" with title "([^"]*)" at URL "([^"]*)"$/) do |title, social_media_service_name, social_media_title, social_media_url|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Add new social media account"
  select social_media_service_name, from: "Service (required)"
  fill_in "URL (required)", with: social_media_url
  fill_in "Title", with: social_media_title
  click_button "Save"
end

And(/^I edit the topical event "([^"]*)" changing the social media account with title "([^"]*)" to "([^"]*)"$/) do |title, _old_social_media_title, new_social_media_title|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Edit"
  fill_in "Title", with: new_social_media_title
  click_button "Save"
end

And(/^I edit the topical event "([^"]*)" deleting the social media account with title "([^"]*)"$/) do |title, _social_media_title|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Delete"
  click_button "Delete"
end

Then(/^I should see the "([^"]*)" social media site has been assigned to the topical event "([^"]*)"$/) do |social_media_title, title|
  @topical_event = EditionableTopicalEvent.find_by(title:)
  expect(@topical_event.social_media_accounts.first.title).to eq(social_media_title)
end

Then(/^I should see the topical event "([^"]*)" has no social media accounts$/) do |title|
  @topical_event = EditionableTopicalEvent.find_by(title:)
  expect(@topical_event.social_media_accounts).to be_empty
end
