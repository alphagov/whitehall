Then /^I should be warned "([^"]*)"$/ do |warning|
  assert page.has_css?(".warning", :text => warning)
end