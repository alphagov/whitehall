When /^I visit the list of policies awaiting review$/ do
  visit submitted_admin_documents_path
end

When /^I view the policy titled "([^"]*)"$/ do |title|
  click_link title
end

Then /^I should see that "([^"]*)" is the policy author$/ do |name|
  assert page.has_css?(".document_view .author", text: name)
end

Then /^I should see that "([^"]*)" is the policy body$/ do |policy_body|
  assert page.has_css?(".document_view .body", text: policy_body)
end
