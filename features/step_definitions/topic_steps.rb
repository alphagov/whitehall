Given /^a policy area called "([^"]*)" exists$/ do |name|
  @topic = create(:topic, name: name)
end

Given /^a policy area called "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create(:topic, name: name, description: description)
end

Given(/^the publication "(.*?)" is associated with the policy area "(.*?)"$/) do |publication_name, topic_name|
  publication = Publication.find_by!(title: publication_name)
  topic = Topic.find_by!(name: topic_name)

  publication.topics << topic
end

Given /^the policy area "([^"]*)" is associated with organisation "([^"]*)"$/ do |topic_name, organisation_name|
  topic = Topic.find_by(name: topic_name) || create(:topic, name: topic_name)
  organisation = Organisation.find_by(name: organisation_name) || create(:ministerial_department, name: organisation_name)
  organisation.topics << topic
end

Given /^the policy area "([^"]*)" has "([^"]*)" as a lead organisation$/ do |topic_name, organisation_name|
  topic = Topic.find_by(name: topic_name) || create(:topic, name: topic_name)
  organisation = Organisation.find_by(name: organisation_name) || create(:ministerial_department, name: organisation_name)
  OrganisationClassification.create(topic: topic, organisation: organisation, lead: true)
end

Given /^two policy areas "([^"]*)" and "([^"]*)" exist$/ do |first_topic, second_topic|
  create(:topic, name: first_topic)
  create(:topic, name: second_topic)
end

Given /^the policy area "([^"]*)" is related to the policy area "([^"]*)"$/ do |name, related_name|
  related_topic = create(:topic, name: related_name)
  topic = Topic.find_by(name: name)
  topic.update_attributes!(related_classifications: [related_topic])
end

Given(/^a (policy area|topical event) called "(.*?)" exists with featured documents$/) do |type, name|
  classification = if type == 'topic'
    create(:topic, name: name)
  else
    create(:topical_event, name: name)
  end

  create(:classification_featuring, classification: classification)
end

Given(/^I have an offsite link "(.*?)" for the policy area "(.*?)"$/) do |title, topic_name|
  topic = Topic.find_by(name: topic_name)
  @offsite_link = create :offsite_link, title: title, parent: topic
end

When /^I create a new policy area "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_topic(name: name, description: description)
end

When /^I create a new policy area "([^"]*)" related to policy area "([^"]*)"$/ do |name, related_name|
  create_topic(name: related_name)
  create_topic(name: name, related_classifications: [related_name])
end

When /^I edit the policy area "([^"]*)" to have description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Policy Areas"
  click_link name
  click_on "Edit"
  fill_in "Description", with: description
  click_button "Save"
end

When /^I visit the list of policy areas$/ do
  visit topics_path
end

When /^I visit the "([^"]*)" (policy area|topical event)$/ do |name, type|
  classification = if type == 'topic'
    Topic.find_by!(name: name)
  else
    TopicalEvent.find_by!(name: name)
  end

  visit polymorphic_path(classification)
end

When /^I set the order of the policies in the "([^"]*)" policy area to:$/ do |name, table|
  topic = Topic.find_by!(name: name)
  visit edit_admin_topic_path(topic)
  table.rows.each_with_index do |(policy_name), index|
    fill_in policy_name, with: index
  end
  click_button "Save"
end

When /^I set the order of the lead organisations in the "([^"]*)" policy area to:$/ do |topic_name, table|
  topic = Topic.find_by!(name: topic_name)
  visit edit_admin_topic_path(topic)

  lead_organisations = table.rows.map { |(organisation_name)| organisation_name }
  lead_organisations.each_with_index do |organisation_name, index|
    fill_in organisation_name, with: index
    fill_in organisation_name + ' is lead?', with: '1'
  end
  other_organisations = topic.organisations.map(&:name) - lead_organisations
  other_organisations.each do |organisation_name|
    fill_in organisation_name, with: ''
    fill_in organisation_name + ' is lead?', with: '0'
  end
  click_button "Save"
end

Then /^I should see in the admin the "([^"]*)" policy area description is "([^"]*)"$/ do |name, description|
  visit admin_topics_path
  assert page.has_css?(".name", text: name)
  assert page.has_css?(".description", text: description)
end

Then /^I should see in the admin the "([^"]*)" policy area is related to policy area "([^"]*)"$/ do |name, related_name|
  visit admin_topics_path
  topic = Topic.find_by(name: name)
  related_topic = Topic.find_by(name: related_name)
  assert page.has_css?("#{record_css_selector(topic)} .related #{record_css_selector(related_topic)}")
end

Then /^I should be able to delete the policy area "([^"]*)"$/ do |name|
  visit admin_topics_path
  click_link name
  click_on 'Edit'
  click_button 'Delete'
end

Then /^I should see the order of the policies in the "([^"]*)" policy area is:$/ do |name, expected_table|
  topic = Topic.find_by!(name: name)
  visit topic_path(topic)
  rows = find("#policies").all('h2')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the order of the lead organisations in the "([^"]*)" policy area is:$/ do |topic_name, expected_table|
  topic = Topic.find_by!(name: topic_name)
  visit edit_admin_topic_path(topic)
  rows = find("#lead_organisation_order").all(:xpath, './/label[./a]')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the following organisations for the "([^"]*)" policy area:$/ do |topic_name, expected_table|
  topic = Topic.find_by!(name: topic_name)
  visit edit_admin_topic_path(topic)
  rows = find("#organisations").all(:xpath, './/label[./a]')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the policy areas "([^"]*)" and "([^"]*)"$/ do |first_topic_name, second_topic_name|
  first_topic = Topic.find_by!(name: first_topic_name)
  second_topic = Topic.find_by!(name: second_topic_name)
  assert page.has_css?(record_css_selector(first_topic), text: first_topic_name)
  assert page.has_css?(record_css_selector(second_topic), text: second_topic_name)
end

Then /^I should see a link to the related policy area "([^"]*)"$/ do |related_name|
  related_topic = Topic.find_by(name: related_name)
  assert page.has_css?(".related-topics a[href='#{topic_path(related_topic)}']", text: related_name)
end

When(/^I feature the publication "([^"]*)" on the policy area "([^"]*)"$/) do |publication_name, topic_name|
  publication = Publication.find_by!(title: publication_name)
  topic = Topic.find_by!(name: topic_name)

  visit admin_topic_path(topic)
  click_on 'Features'

  within record_css_selector(publication) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", jpg_image
  fill_in :classification_featuring_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When(/^I add the offsite link "(.*?)" of type "(.*?)" to the policy area "(.*?)"$/) do |title, type, topic_name|
  topic = Topic.find_by!(name: topic_name)
  visit admin_topic_classification_featurings_path(topic)
  click_link "Create an offsite link"
  fill_in :offsite_link_title, with: title
  select type, from: 'offsite_link_link_type'
  fill_in :offsite_link_summary, with: "summary"
  fill_in :offsite_link_url, with: "http://gov.uk"
  click_button "Save"
end

When(/^I feature the offsite link "(.*?)" for policy area "(.*?)" with image "(.*?)"$/) do |offsite_link_title, topic_name, image_filename|
  topic = Topic.find_by!(name: topic_name)
  visit admin_topic_classification_featurings_path(topic)
  @offsite_link = OffsiteLink.find_by(title: offsite_link_title)
  within record_css_selector(@offsite_link) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :classification_featuring_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

Then(/^I should see the publication "([^"]*)" featured on the public policy area page for "([^"]*)"$/) do |publication_name, topic_name|
  publication = Publication.find_by!(title: publication_name)
  topic = Topic.find_by!(name: topic_name)

  visit topic_path(topic)

  within('section.featured-news') do
    assert page.has_content?(publication.title)
  end
end

Then(/^I should see the offsite link featured on the public policy area page$/) do
  visit topic_path(@topic)
  within('section.featured-news') do
    assert page.has_content?(@offsite_link.title)
  end
end

When /^I add some featured links to the policy area "([^"]*)" via the admin$/ do |topic_name|
  topic = Topic.find_by!(name: topic_name)
  visit admin_topic_path(topic)
  click_link "Edit"
  within ".featured-links" do
    fill_in "Url", with: "https://www.gov.uk/mainstream/tool-alpha"
    fill_in "Title", with: "Tool Alpha"
  end
  click_button "Save"
end

Then /^the featured links for the policy area "([^"]*)" should be visible on the public site$/ do |topic_name|
  visit_topic topic_name
  within ".featured-links" do
    assert page.has_css?("a[href='https://www.gov.uk/mainstream/tool-alpha']", "Tool Alpha")
  end
end

Then(/^I should see the edit offsite link "(.*?)" on the "(.*?)" policy area page$/) do |title, topic_name|
  topic = Topic.find_by!(name: topic_name)
  offsite_link = OffsiteLink.find_by!(title: title)
  visit admin_topic_path(topic)
  page.has_link?(title, href: edit_admin_topic_offsite_link_path(topic.id, offsite_link.id))
end

When(/^I start creating a policy area$/) do
  start_creating_topic
end
