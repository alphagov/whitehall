Given(/^a topical event called "(.*?)" with description "(.*?)"$/) do |name, description|
  @topical_event = create(:topical_event, name: name, description: description)
  stub_topical_event_in_content_store(name)
end

Given(/^I have an offsite link "(.*?)" for the topical event "(.*?)"$/) do |title, topical_event_name|
  topical_event = TopicalEvent.find_by(name: topical_event_name)
  @offsite_link = create :offsite_link, title: title, parent: topical_event
end

When /^I create a new topical event "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_topical_event_and_stub_in_content_store(name: name, description: description)
end

When /^I create a new topical event "([^"]*)" with description "([^"]*)" and it ends today$/ do |name, description|
  create_topical_event_and_stub_in_content_store(name: name, description: description, start_date: 2.months.ago.to_date.to_s, end_date: Date.today.to_s)
end

Then /^I should see the topical event "([^"]*)" on the frontend is archived$/ do |topical_event_name|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  visit topical_event_path(topical_event)
  assert page.has_css?(".archived", text: "Archived")
end

Then /^I should see the topical event "([^"]*)" in the admin interface$/ do |topical_event_name|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  visit admin_topical_events_path(topical_event)
  assert page.has_css?(record_css_selector(topical_event))
end

Then /^I should see the topical event "([^"]*)" on the frontend$/ do |topical_event_name|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  visit topical_event_path(topical_event)
  assert page.has_css?(record_css_selector(topical_event))
end

When /^I draft a new speech "([^"]*)" relating it to topical event "([^"]*)"$/ do |speech_name, topical_event_name|
  begin_drafting_speech title: speech_name
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

When /^I draft a new news article "([^"]*)" relating it to topical event "([^"]*)"$/ do |news_article_title, topical_event_name|
  begin_drafting_news_article title: news_article_title
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

When /^I draft a new publication "([^"]*)" relating it to topical event "([^"]*)"$/ do |publication_title, topical_event_name|
  begin_drafting_publication publication_title
  select topical_event_name, from: "Topical events"
  click_button "Save"
  add_external_attachment
end

When /^I draft a new consultation "([^"]*)" relating it to topical event "([^"]*)"$/ do |consultation_title, topical_event_name|
  begin_drafting_consultation title: consultation_title
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

When /^I draft a new document collection "([^"]*)" relating it to topical event "([^"]*)"$/ do |document_collection_title, topical_event_name|
  begin_drafting_document_collection title: document_collection_title
  select topical_event_name, from: "Topical events"
  click_button "Save"
end

When(/^I add the offsite link "(.*?)" of type "(.*?)" to the topical event "(.*?)"$/) do |title, type, topical_event_name|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  visit admin_topical_event_classification_featurings_path(topical_event)
  click_link "Create a non-GOV.UK government link"
  fill_in :offsite_link_title, with: title
  select type, from: 'offsite_link_link_type'
  fill_in :offsite_link_summary, with: "summary"
  fill_in :offsite_link_url, with: "http://gov.uk"
  click_button "Save"
end

Then /^I should see (#{THE_DOCUMENT}) in the (announcements|publications|consultations) section of the topical event "([^"]*)"$/ do |edition, section, topical_event_name|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  visit topical_event_path(topical_event)
  within "##{section}" do
    assert page.has_css?(record_css_selector(edition))
  end
end

When /^I feature the document "([^"]*)" for topical event "([^"]*)" with image "([^"]*)"$/ do |news_article_title, topical_event_name, image_filename|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  visit admin_topical_event_classification_featurings_path(topical_event)
  edition = Edition.find_by(title: news_article_title)
  within record_css_selector(edition) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :classification_featuring_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When(/^I feature the offsite link "(.*?)" for topical event "(.*?)" with image "(.*?)"$/) do |offsite_link_title, topical_event_name, image_filename|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  visit admin_topical_event_classification_featurings_path(topical_event)
  offsite_link = OffsiteLink.find_by(title: offsite_link_title)
  within record_css_selector(offsite_link) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :classification_featuring_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

Then /^I should see the featured (documents|offsite links) in the "([^"]*)" topical event are:$/ do |type, name, expected_table|
  visit topical_event_path(TopicalEvent.find_by!(name: name))
  rows = find('.featured-news').all('.feature')
  table = rows.collect do |row|
    [
      row.find('h2').text.strip,
      File.basename(row.find('.featured-image')['src'])
    ]
  end
  expected_table.diff!(table)
end

Then(/^I should see the edit offsite link "(.*?)" on the "(.*?)" topical event page$/) do |title, topical_event_name|
  topical_event = TopicalEvent.find_by!(name: topical_event_name)
  offsite_link = OffsiteLink.find_by!(title: title)
  visit topical_event_path(topical_event)
  page.has_link?(title, href: edit_admin_topical_event_offsite_link_path(topical_event.id, offsite_link.id))
end

Given(/^I'm administering a topical event$/) do
  event = create(:topical_event, name: "Name of event")
  stub_topical_event_in_content_store("Name of event")
  visit admin_topical_event_path(event)
end

When(/^I add a page of information about the event$/) do
  click_link 'About page'
  click_link 'Create'
  fill_in 'Name', with: 'Page about the event'
  fill_in 'Read more link text', with: 'Read more about this event'
  fill_in 'Summary', with: 'Summary'
  fill_in 'Body', with: 'Body'
  click_button 'Save'
end

Then(/^I should be able to edit the event's about page$/) do
  click_link 'Edit'
  fill_in 'Name', with: 'About the event'
  click_button 'Save'
end

Then(/^a link to the event's about page is visible$/) do
  click_link 'View on website'
  assert page.has_css?('a[href$="/about"]', text: 'Read more about this event')
end

Given /^a topical event with published documents$/ do
  name = 'Topical Event with Published Documents'
  @topical_event = create(:topical_event, name: name)
  stub_topical_event_in_content_store(name)
  create_recently_published_documents_for_topical_event(@topical_event)
end

When /^I view that topical event page$/ do
  visit topical_event_path(@topical_event)
end

Then /^I should be able to delete the topical event "([^"]*)"$/ do |name|
  topical_event = TopicalEvent.find_by!(name: name)
  visit admin_topical_event_path(topical_event)
  click_on 'Edit'
  click_button 'Delete'
  refute TopicalEvent.exists?(topical_event.id)
end
