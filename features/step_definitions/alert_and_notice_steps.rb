Then /^I should be alerted "([^"]*)"$/ do |alert|
  assert page.has_css?(".alert", text: alert)
end

Then /^I should be notified "([^"]*)"$/ do |notice|
  assert page.has_css?(".notice", text: notice)
end