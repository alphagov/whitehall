Given /^a fact checker has commented "([^"]*)" on the draft policy titled "([^"]*)"$/ do |comment, title|
  document = create(:draft_policy, title: title)
  create(:fact_check_request, document: document, comments: comment)
end

Then /^"([^"]*)" should be notified by email that "([^"]*)" has requested a fact check$/ do |email_address, writer_name|
  Then %{"#{email_address}" should receive an email}
  When %{I open the last email sent to "#{email_address}"}
  Then %{I should see "Fact checking request from #{writer_name}" in the email subject}
end

Then /^they provide feedback "([^"]*)"$/ do |comments|
  fill_in "Comments", with: comments
  click_button "Submit"
end