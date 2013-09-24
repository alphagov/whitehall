Given /^a topic called "([^"]*)" exists$/ do |name|
  create(:topic, name: name)
end

Given /^a topic called "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create(:topic, name: name, description: description)
end

Given /^the topic "([^"]*)" contains some policies$/ do |topic_name|
  @topic = create(:topic, name: topic_name)
  5.times do create(:published_policy, topics: [@topic]); end
  2.times do create(:draft_policy,     topics: [@topic]); end
end

Given /^the topic "([^"]*)" is associated with organisation "([^"]*)"$/ do |topic_name, organisation_name|
  topic = Topic.find_by_name(topic_name) || create(:topic, name: topic_name)
  organisation = Organisation.find_by_name(organisation_name) || create(:ministerial_department, name: organisation_name)
  organisation.topics << topic
end

Given /^the topic "([^"]*)" has "([^"]*)" as a lead organisation$/ do |topic_name, organisation_name|
  topic = Topic.find_by_name(topic_name) || create(:topic, name: topic_name)
  organisation = Organisation.find_by_name(organisation_name) || create(:ministerial_department, name: organisation_name)
  OrganisationClassification.create(topic: topic, organisation: organisation, lead: true)
end

Given /^the topic "([^"]*)" contains a published and a draft detailed guide$/ do |topic_name|
  detailed_guides = [build(:published_detailed_guide), build(:draft_detailed_guide)]
  create(:topic, name: topic_name, detailed_guides: detailed_guides)
end

Given /^two topics "([^"]*)" and "([^"]*)" exist$/ do |first_topic, second_topic|
  create(:topic, name: first_topic)
  create(:topic, name: second_topic)
end

Given /^other topics also have policies$/ do
  create(:topic, policies: [build(:published_policy)])
  create(:topic, policies: [build(:published_policy)])
end

Given /^the topic "([^"]*)" is related to the topic "([^"]*)"$/ do |name, related_name|
  related_topic = create(:topic, name: related_name)
  topic = Topic.find_by_name(name)
  topic.update_attributes!(related_classifications: [related_topic])
end

When /^I create a new topic "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_topic(name: name, description: description)
end

When /^I create a new topic "([^"]*)" related to topic "([^"]*)"$/ do |name, related_name|
  create_topic(name: related_name)
  create_topic(name: name, related_classifications: [related_name])
end

When /^I edit the topic "([^"]*)" to have description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Topics"
  click_link name
  click_on "Edit"
  fill_in "Description", with: description
  click_button "Save"
end

When /^I visit the list of topics$/ do
  visit topics_path
end

When /^I visit the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name!(name)
  visit topic_path(topic)
end

When /^I set the order of the policies in the "([^"]*)" topic to:$/ do |name, table|
  topic = Topic.find_by_name!(name)
  visit edit_admin_topic_path(topic)
  table.rows.each_with_index do |(policy_name), index|
    fill_in policy_name, with: index
  end
  click_button "Save"
end

When /^I set the order of the lead organisations in the "([^"]*)" topic to:$/ do |topic_name, table|
  topic = Topic.find_by_name!(topic_name)
  visit edit_admin_topic_path(topic)

  lead_organisations = table.rows.map { |(organisation_name)| organisation_name }
  lead_organisations.each_with_index do |organisation_name, index|
    fill_in organisation_name, with: index
    fill_in organisation_name+' is lead?', with: '1'
  end
  other_organisations = topic.organisations.map(&:name) - lead_organisations
  other_organisations.each do |organisation_name|
    fill_in organisation_name, with: ''
    fill_in organisation_name+' is lead?', with: '0'
  end
  click_button "Save"
end

Then /^I should see in the admin the "([^"]*)" topic description is "([^"]*)"$/ do |name, description|
  visit admin_topics_path
  assert page.has_css?(".name", text: name)
  assert page.has_css?(".description", text: description)
end

Then /^I should see in the admin the "([^"]*)" topic is related to topic "([^"]*)"$/ do |name, related_name|
  visit admin_topics_path
  topic = Topic.find_by_name(name)
  related_topic = Topic.find_by_name(related_name)
  assert page.has_css?("#{record_css_selector(topic)} .related #{record_css_selector(related_topic)}")
end

Then /^I should be able to delete the topic "([^"]*)"$/ do |name|
  visit admin_topics_path
  click_link name
  click_on 'Edit'
  click_button 'Delete'
end

Then /^I should see the order of the policies in the "([^"]*)" topic is:$/ do |name, expected_table|
  topic = Topic.find_by_name!(name)
  visit topic_path(topic)
  rows = find("#policies").all('h2')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the order of the lead organisations in the "([^"]*)" topic is:$/ do |topic_name, expected_table|
  topic = Topic.find_by_name!(topic_name)
  visit edit_admin_topic_path(topic)
  rows = find("#lead_organisation_order").all(:xpath, './/label[./a]')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the following organisations for the "([^"]*)" topic:$/ do |topic_name, expected_table|
  topic = Topic.find_by_name!(topic_name)
  visit edit_admin_topic_path(topic)
  rows = find("#organisations").all(:xpath, './/label[./a]')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should only see published policies belonging to the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name!(name)
  actual_editions = records_from_elements(Edition, page.all(".policy")).sort_by(&:id)
  expected_editions = topic.policies.published.all.sort_by(&:id)
  assert_equal expected_editions, actual_editions
end

Then /^I should only see published detailed guides belonging to the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name!(name)
  actual_editions = records_from_elements(Edition, page.all(".detailed_guide")).sort_by(&:id)
  expected_editions = topic.detailed_guides.published.all.sort_by(&:id)
  assert_equal expected_editions, actual_editions
end

Then /^I should see the topics "([^"]*)" and "([^"]*)"$/ do |first_topic_name, second_topic_name|
  first_topic = Topic.find_by_name!(first_topic_name)
  second_topic = Topic.find_by_name!(second_topic_name)
  assert page.has_css?(record_css_selector(first_topic), text: first_topic_name)
  assert page.has_css?(record_css_selector(second_topic), text: second_topic_name)
end

Then /^I should see links to the "([^"]*)" and "([^"]*)" topics$/ do |topic_1_name, topic_2_name|
  topic_1 = Topic.find_by_name!(topic_1_name)
  topic_2 = Topic.find_by_name!(topic_2_name)
  assert page.has_css?("a[href='#{topic_path(topic_1)}']", text: topic_1_name)
  assert page.has_css?("a[href='#{topic_path(topic_2)}']", text: topic_2_name)
end

Then /^I should see a link to the related topic "([^"]*)"$/ do |related_name|
  related_topic = Topic.find_by_name(related_name)
  assert page.has_css?(".related-topics a[href='#{topic_path(related_topic)}']", text: related_name)
end

When(/^I feature one of the policies on the topic$/) do
  @policy = @topic.policies.published.last
  visit admin_topic_path(@topic)
  click_on 'Features'

  within record_css_selector(@policy) do
    click_link "Feature"
  end
  attach_file "Select an image to be shown when featuring", jpg_image
  fill_in :classification_featuring_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

Then(/^I should see the policy featured on the public topic page$/) do
  visit topic_path(@topic)
  within('section.featured-news') do
    assert page.has_content?(@policy.title)
  end
end
