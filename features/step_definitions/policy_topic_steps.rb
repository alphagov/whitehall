Given /^a policy topic called "([^"]*)"$/ do |name|
  create(:policy_topic, name: name)
end

Given /^a policy topic called "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_policy_topic(name: name, description: description)
end

Given /^the policy topic "([^"]*)" contains some policies$/ do |name|
  policies = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:policy_topic, name: name, policies: policies)
end

Given /^two policy topics "([^"]*)" and "([^"]*)" exist$/ do |first_policy_topic, second_policy_topic|
  create(:policy_topic, name: first_policy_topic)
  create(:policy_topic, name: second_policy_topic)
end

Given /^other policy topics also have policies$/ do
  create(:policy_topic, policies: [build(:published_policy)])
  create(:policy_topic, policies: [build(:published_policy)])
end

Given /^the policy topic "([^"]*)" is related to the policy topic "([^"]*)"$/ do |name, related_name|
  related_policy_topic = create(:policy_topic, name: related_name)
  policy_topic = PolicyTopic.find_by_name(name)
  policy_topic.update_attributes!(related_policy_topics: [related_policy_topic])
end

When /^I create a new policy topic "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create_policy_topic(name: name, description: description)
end

When /^I create a new policy topic "([^"]*)" related to policy topic "([^"]*)"$/ do |name, related_name|
  create_policy_topic(name: related_name)
  create_policy_topic(name: name, related_policy_topics: [related_name])
end

When /^I edit the policy topic "([^"]*)" to have description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Policy topics"
  click_link name
  fill_in "Description", with: description
  click_button "Save"
end

When /^I visit the list of policy topics$/ do
  visit policy_topics_path
end

When /^I visit the "([^"]*)" policy topic$/ do |name|
  policy_topic = PolicyTopic.find_by_name!(name)
  visit policy_topic_path(policy_topic)
end

When /^I set the order of the policies in the "([^"]*)" policy topic to:$/ do |name, table|
  policy_topic = PolicyTopic.find_by_name!(name)
  visit edit_admin_policy_topic_path(policy_topic)
  table.rows.each_with_index do |(policy_name), index|
    fill_in policy_name, with: index
  end
  click_button "Save"
end

When /^I set the featured policies in the "([^"]*)" policy topic to:$/ do |name, table|
  policy_topic = PolicyTopic.find_by_name!(name)
  visit edit_admin_policy_topic_path(policy_topic)
  table.rows.each_with_index do |(policy_name), index|
    policy = Policy.find_by_title(policy_name)
    within record_css_selector(policy) do
      check "Featured?"
    end
  end
  click_button "Save"
end

Then /^I should see the "([^"]*)" policy topic description is "([^"]*)"$/ do |name, description|
  visit policy_topics_path
  click_link name
  assert page.has_css?(".description", text: description)
end

Then /^I should see in the admin the "([^"]*)" policy topic description is "([^"]*)"$/ do |name, description|
  visit admin_policy_topics_path
  assert page.has_css?(".name", text: name)
  assert page.has_css?(".description", text: description)
end

Then /^I should see in the admin the "([^"]*)" policy topic is related to policy topic "([^"]*)"$/ do |name, related_name|
  visit admin_policy_topics_path
  policy_topic = PolicyTopic.find_by_name(name)
  related_policy_topic = PolicyTopic.find_by_name(related_name)
  assert page.has_css?("#{record_css_selector(policy_topic)} .related #{record_css_selector(related_policy_topic)}")
end

Then /^I should be able to delete the policy topic "([^"]*)"$/ do |name|
  visit admin_policy_topics_path
  click_link name
  click_button 'Delete'
end

Then /^I should see the featured policies in the "([^"]*)" policy topic are:$/ do |name, expected_table|
  policy_topic = PolicyTopic.find_by_name!(name)
  visit policy_topic_path(policy_topic)
  rows = find("ul.featured.policies").all('li')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the order of the policies in the "([^"]*)" policy topic is:$/ do |name, expected_table|
  policy_topic = PolicyTopic.find_by_name!(name)
  visit policy_topic_path(policy_topic)
  rows = find("#policies").all('h2')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should only see published policies belonging to the "([^"]*)" policy topic$/ do |name|
  policy_topic = PolicyTopic.find_by_name!(name)
  documents = records_from_elements(Edition, page.all(".document"))
  assert documents.all? { |document| policy_topic.documents.published.include?(document) }
end

Then /^I should see the policy topics "([^"]*)" and "([^"]*)"$/ do |first_policy_topic_name, second_policy_topic_name|
  first_policy_topic = PolicyTopic.find_by_name!(first_policy_topic_name)
  second_policy_topic = PolicyTopic.find_by_name!(second_policy_topic_name)
  assert page.has_css?(record_css_selector(first_policy_topic), text: first_policy_topic_name)
  assert page.has_css?(record_css_selector(second_policy_topic), text: second_policy_topic_name)
end

Then /^I should see links to the "([^"]*)" and "([^"]*)" policy topics$/ do |policy_topic_1_name, policy_topic_2_name|
  policy_topic_1 = PolicyTopic.find_by_name!(policy_topic_1_name)
  policy_topic_2 = PolicyTopic.find_by_name!(policy_topic_2_name)
  assert page.has_css?("a[href='#{policy_topic_path(policy_topic_1)}']", text: policy_topic_1_name)
  assert page.has_css?("a[href='#{policy_topic_path(policy_topic_2)}']", text: policy_topic_2_name)
end

Then /^I should see a link to the related policy topic "([^"]*)"$/ do |related_name|
  related_policy_topic = PolicyTopic.find_by_name(related_name)
  assert page.has_css?("#related_policy_topics a[href='#{policy_topic_path(related_policy_topic)}']", text: related_name)
end

Then /^I should see a link to the policy topic "([^"]*)"$/ do |name|
  policy_topic = PolicyTopic.find_by_name(name)
  assert page.has_css?("a[href='#{policy_topic_path(policy_topic)}']", text: name)
end

def create_policy_topic(options = {})
  visit admin_root_path
  click_link "Policy topics"
  click_link "Create Policy Area"
  fill_in "Name", with: options[:name] || "policy-topic-name"
  fill_in "Description", with: options[:description] || "policy-topic-description"
  (options[:related_policy_topics] || []).each do |related_name|
    select related_name, from: "Related policy topics"
  end
  click_button "Save"
end
