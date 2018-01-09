Then(/^(?:I|they) should be notified "([^"]*)"$/) do |notice|
  assert page.has_css?(".flash.notice", text: notice)
end
