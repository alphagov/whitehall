Given /^the topic "([^"]*)" contains some policies$/ do |name|
  policies = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:topic, name: name, policies: policies)
end

Given /^other topics also have policies$/ do
  create(:topic, policies: [build(:published_policy)])
  create(:topic, policies: [build(:published_policy)])
end

When /^I visit the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name(name)
  visit topic_path(topic)
end

Then /^I should only see published policies belonging to the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name(name)
  policies = records_from_elements(Policy, page.all(".policy"))
  assert policies.all? { |policy| topic.policies.published.include? policy }
end
