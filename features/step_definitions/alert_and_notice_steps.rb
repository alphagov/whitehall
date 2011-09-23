Then /^I should be alerted "([^"]*)"$/ do |warning|
  assert page.has_css?(".alert", text: warning)
end

Then /^I should be notified "([^"]*)"$/ do |notice|
  assert page.has_css?(".notice", text: notice)
end