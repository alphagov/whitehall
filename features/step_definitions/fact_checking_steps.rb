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
  Notifications.fact_check_request(fact_check_request, host: "example.com").deliver
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

Given /^"([^"]*)" has asked "([^"]*)" for feedback on the draft policy "([^"]*)"$/ do |requestor_email, fact_checker_email, title|
  requestor = create(:user, email_address: requestor_email)
  document = create(:draft_policy, title: title)
  create(:fact_check_request, requestor: requestor, document: document, email_address: fact_checker_email)
end

When /^"([^"]*)" adds feedback "([^"]*)" to "([^"]*)"$/ do |fact_checker_email, comments, title|
  fact_check_request = FactCheckRequest.find_all_by_email_address(fact_checker_email).last
  visit edit_admin_fact_check_request_path(fact_check_request)
  fill_in "Comments", with: comments
  click_button "Submit"
end

Then /^"([^"]*)" should be notified by email that "([^"]*)" has added a comment "([^"]*)" to "([^"]*)"$/ do |requestor_email, fact_checker_email, comment, title|
  assert_equal 1, unread_emails_for(requestor_email).size
  email = unread_emails_for(requestor_email).last
  assert_equal "Fact check comment added by #{fact_checker_email}: #{title}", email.subject
end
