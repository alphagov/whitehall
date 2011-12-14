When /^I search for "([^"]*)"$/ do |text|
  visit search_path
  fill_in "Text", with: text
  click_button "Search"
end

Then /^I see the policy "([^"]*)" in the search results$/ do |title|
  policy = Policy.find_by_title!(title)
  assert page.has_css?(record_css_selector(policy))
end

Then /^I do not see the policy "([^"]*)" in the search results$/ do |title|
  policy = Policy.find_by_title!(title)
  refute page.has_css?(record_css_selector(policy))
end
