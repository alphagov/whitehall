Given /^the topic "([^"]*)" contains some policies$/ do |name|
  editions = Array.new(5) { build(:published_edition) } + Array.new(2) { build(:draft_edition) }
  create(:topic, name: name, editions: editions)
end

Given /^other topics also have policies$/ do
  create(:topic, editions: [build(:published_edition)])
  create(:topic, editions: [build(:published_edition)])
end

When /^I visit the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name(name)
  visit topic_path(topic)
end

Then /^I should only see published policies belonging to the "([^"]*)" topic$/ do |name|
  topic = Topic.find_by_name(name)
  policies = records_from_elements(Policy, page.all(".policy"))
  assert policies.all? { |policy| topic.documents.published.include? policy }
end
