Given /^a fact checker has commented "([^"]*)" on the draft policy "([^"]*)"$/ do |comment, title|
  document = create(:draft_policy, title: title)
  create(:fact_check_request, document: document, comments: comment)
end

Then /^"([^"]*)" should be notified by email that "([^"]*)" has requested a fact check for "([^"]*)" with instructions "([^"]*)"$/ do |email_address, writer_name, title, instructions|
  assert_equal 1, unread_emails_for(email_address).size
  email = unread_emails_for(email_address).last
  assert_equal "Fact checking request from #{writer_name}: #{title}", email.subject
  assert_match /#{instructions}/, email.body.to_s
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy "([^"]*)"$/ do |email, title|
  policy = create(:draft_policy, title: title)
  fact_check_request = create(:fact_check_request, document: policy, email_address: email)
  Notifications.fact_check(fact_check_request, host: "example.com").deliver
end

When /^"([^"]*)" clicks the email link to the draft policy$/ do |email_address|
  email = unread_emails_for(email_address).last
  links = URI.extract(email.body.to_s, ["http", "https"])
  visit links.first
end

Then /^they provide feedback "([^"]*)"$/ do |comments|
  fill_in "Comments", with: comments
  click_button "Submit"
end