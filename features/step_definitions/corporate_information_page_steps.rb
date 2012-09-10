Given /^I add a "([^"]*)" corporate information page to "([^"]*)" with body "([^"]*)"$/ do |page_type, org_name, body|
  organisation = Organisation.find_by_name(org_name)
  visit admin_organisation_path(organisation)
  click_link "New corporate information page"
  fill_in "Body", with: body
  select page_type, from: "Type"
  click_button "Save"
end

When /^I click the "([^"]*)" link$/ do |link_text|
  click_link link_text
end

Then /^I should see the text "([^"]*)"$/ do |text|
  assert has_css?("body", text: Regexp.new(Regexp.escape(text)))
end
