Given /^a topic called "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create(:topic, name: name, description: description, documents: [create(:published_policy)])
end

When /^I create a new topic "([^"]*)" with description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Topics"
  click_link "Create Topic"
  fill_in "Name", with: name
  fill_in "Description", with: description
  click_button "Save"
end

When /^I edit the topic "([^"]*)" to have description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Topics"
  click_link name
  fill_in "Description", with: description
  click_button "Save"
end

Then /^I should see the "([^"]*)" topic description is "([^"]*)"$/ do |name, description|
  visit topics_path
  click_link name
  assert page.has_css?(".description", text: description)
end

Then /^I should see in the admin the "([^"]*)" topic description is "([^"]*)"$/ do |name, description|
  visit admin_topics_path
  assert page.has_css?(".name", text: name)
  assert page.has_css?(".description", text: description)
end

Then /^I should be able to delete the topic "([^"]*)"$/ do |name|
  visit admin_topics_path
  topic = Topic.find_by_name(name)
  within(record_css_selector(topic)) do
    click_button 'delete'
  end
end

Given /^the topic "([^"]*)" contains some policies$/ do |name|
  documents = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:topic, name: name, documents: documents)
end

Given /^two topics "([^"]*)" and "([^"]*)" exist$/ do |first_topic, second_topic|
  create(:topic, name: first_topic)
  create(:topic, name: second_topic)
end

Given /^other topics also have policies$/ do
  create(:topic, documents: [build(:published_policy)])
  create(:topic, documents: [build(:published_policy)])
end

When /^I visit the list of topics$/ do
  visit topics_path
end

When /^I visit the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name(name)
  visit topic_path(topic)
end

Then /^I should only see published policies belonging to the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name(name)
  documents = records_from_elements(Document, page.all(".document"))
  assert documents.all? { |document| topic.documents.published.include?(document) }
end

Then /^I should see the topics "([^"]*)" and "([^"]*)"$/ do |first_topic_name, second_topic_name|
  first_topic = Topic.find_by_name(first_topic_name)
  second_topic = Topic.find_by_name(second_topic_name)
  assert page.has_css?(record_css_selector(first_topic), text: first_topic_name)
  assert page.has_css?(record_css_selector(second_topic), text: second_topic_name)
end

Then /^I should see links to the "([^"]*)" and "([^"]*)" topics$/ do |topic_1_name, topic_2_name|
  topic_1 = Topic.find_by_name(topic_1_name)
  topic_2 = Topic.find_by_name(topic_2_name)
  assert page.has_css?("#topics a[href='#{topic_path(topic_1)}']", text: topic_1_name)
  assert page.has_css?("#topics a[href='#{topic_path(topic_2)}']", text: topic_2_name)
end