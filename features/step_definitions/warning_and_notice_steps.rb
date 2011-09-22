Then /^I should be warned "([^"]*)"$/ do |warning|
  assert page.has_css?(".warning", :text => warning)
end

Then /^I should be notified "([^"]*)"$/ do |notice|
  assert page.has_css?(".notice", :text => notice)
end