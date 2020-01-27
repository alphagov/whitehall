Then(/^(?:I|they) should be notified "([^"]*)"$/) do |notice|
  assert_selector ".flash.notice", text: notice
end
