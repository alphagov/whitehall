Then(/^(?:I|they) should be notified "([^"]*)"$/) do |notice|
  expect(page).to have_selector(".flash.notice", text: notice)
end
