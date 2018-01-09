Given(/^a fact checker has commented "([^"]*)" on the draft publication "([^"]*)"$/) do |comment, title|
  edition = create(:draft_publication, title: title)
  create(:fact_check_request, edition: edition, comments: comment)
end

Given(/^"([^"]*)" has received an email requesting they fact check a draft publication "([^"]*)"$/) do |email, title|
  publication = create(:draft_publication, title: title)
  fact_check_request = create(:fact_check_request, edition: publication, email_address: email)
  Notifications.fact_check_request(fact_check_request, host: "example.com").deliver_now
end

Given(/^"([^"]*)" has asked "([^"]*)" for feedback on the draft publication "([^"]*)"$/) do |requestor_email, fact_checker_email, title|
  requestor = create(:user, email: requestor_email)
  edition = create(:draft_publication, title: title)
  create(:fact_check_request, requestor: requestor, edition: edition, email_address: fact_checker_email)
end

Given(/^a published publication called "([^"]*)" with feedback "([^"]*)" exists$/) do |title, comments|
  publication = create(:published_publication, title: title)
  fact_check_request = create(:fact_check_request,
                              edition: publication,
                              email_address: "user@example.com",
                              comments: comments)
end

When(/^"([^"]*)" clicks the email link to the draft publication$/) do |email_address|
  email = unread_emails_for(email_address).last
  links = URI.extract(email.body.to_s, %w[http https])
  visit links.first
end

When(/^"([^"]*)" adds feedback "([^"]*)" to "([^"]*)"$/) do |fact_checker_email, comments, _title|
  fact_check_request = FactCheckRequest.find_by(email_address: fact_checker_email)
  visit edit_admin_fact_check_request_path(fact_check_request)
  fill_in "Comments", with: comments
  click_button "Submit"
end

Then(/^they provide feedback "([^"]*)"$/) do |comments|
  fill_in "Comments", with: comments
  click_button "Submit"
end

Then(/^"([^"]*)" should be notified by email that "([^"]*)" has requested a fact check for "([^"]*)" with instructions "([^"]*)"$/) do |email_address, writer_name, title, instructions|
  assert_equal 1, unread_emails_for(email_address).size
  email = unread_emails_for(email_address).last
  assert_equal "Fact checking request from #{writer_name}: #{title}", email.subject
  assert_match %r[#{instructions}], email.body.to_s
end

Then(/^"([^"]*)" should be notified by email that "([^"]*)" has added a comment "([^"]*)" to "([^"]*)"$/) do |requestor_email, fact_checker_email, _comment, title|
  assert_equal 1, unread_emails_for(requestor_email).size
  email = unread_emails_for(requestor_email).last
  assert_equal "Fact check comment added by #{fact_checker_email}: #{title}", email.subject
end
