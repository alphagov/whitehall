Given /^a topic called "([^"]*)"$/ do |name|
  create(:topic, name: name)
end

Given /^a topic called "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_topic(name: name, description: description)
end

Given /^the topic "([^"]*)" contains some policies$/ do |topic_name|
  policies = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:topic, name: topic_name, policies: policies)
end

Given /^the topic "([^"]*)" contains a published and a draft specialist guide$/ do |topic_name|
  specialist_guides = [build(:published_specialist_guide), build(:draft_specialist_guide)]
  create(:topic, name: topic_name, specialist_guides: specialist_guides)
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
  topic.update_attributes!(related_topics: [related_topic])
end

When /^I create a new topic "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_topic(name: name, description: description)
end

When /^I create a new topic "([^"]*)" related to topic "([^"]*)"$/ do |name, related_name|
  create_topic(name: related_name)
  create_topic(name: name, related_topics: [related_name])
end

When /^I edit the topic "([^"]*)" to have description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Topics"
  click_link name
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

When /^I set the featured policies in the "([^"]*)" topic to:$/ do |name, table|
  topic = Topic.find_by_name!(name)
  visit edit_admin_topic_path(topic)
  table.rows.each_with_index do |(policy_name), index|
    policy = Policy.find_by_title(policy_name)
    within record_css_selector(policy) do
      check "Featured?"
    end
  end
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

Then /^I should see in the admin the "([^"]*)" topic is related to topic "([^"]*)"$/ do |name, related_name|
  visit admin_topics_path
  topic = Topic.find_by_name(name)
  related_topic = Topic.find_by_name(related_name)
  assert page.has_css?("#{record_css_selector(topic)} .related #{record_css_selector(related_topic)}")
end

Then /^I should be able to delete the topic "([^"]*)"$/ do |name|
  visit admin_topics_path
  click_link name
  click_button 'Delete'
end

Then /^I should see the featured policies in the "([^"]*)" topic are:$/ do |name, expected_table|
  topic = Topic.find_by_name!(name)
  visit topic_path(topic)
  rows = find("ul.featured-policies").all('li')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the order of the policies in the "([^"]*)" topic is:$/ do |name, expected_table|
  topic = Topic.find_by_name!(name)
  visit topic_path(topic)
  rows = find("#policies").all('h2')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should only see published policies belonging to the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name!(name)
  actual_editions = records_from_elements(Edition, page.all(".policy")).sort_by(&:id)
  expected_editions = topic.policies.published.all.sort_by(&:id)
  assert_equal expected_editions, actual_editions
end

Then /^I should only see published specialist guides belonging to the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name!(name)
  actual_editions = records_from_elements(Edition, page.all(".specialist_guide")).sort_by(&:id)
  expected_editions = topic.specialist_guides.published.all.sort_by(&:id)
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
  assert page.has_css?("#related_topics a[href='#{topic_path(related_topic)}']", text: related_name)
end

Then /^I should see a link to the topic "([^"]*)"$/ do |name|
  topic = Topic.find_by_name(name)
  assert page.has_css?("a[href='#{topic_path(topic)}']", text: name)
end

def create_topic(options = {})
  visit admin_root_path
  click_link "Topics"
  click_link "Create topic"
  fill_in "Name", with: options[:name] || "topic-name"
  fill_in "Description", with: options[:description] || "topic-description"
  (options[:related_topics] || []).each do |related_name|
    select related_name, from: "Related topics"
  end
  click_button "Save"
end
