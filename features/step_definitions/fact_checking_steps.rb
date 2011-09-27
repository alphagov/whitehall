Then /^"([^"]*)" should receive an email requesting fact checking$/ do |email_address|
  assert_equal 1, ActionMailer::Base.deliveries.length
  fact_check_email = ActionMailer::Base.deliveries.first
  assert_equal email_address, fact_check_email.to.first
  assert_match /fact checking request/i, fact_check_email.subject
end