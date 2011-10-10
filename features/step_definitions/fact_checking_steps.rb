Given /^a fact checker has commented "([^"]*)" on the draft policy titled "([^"]*)"$/ do |comment, title|
  edition = create(:draft_policy, title: title)
  create(:fact_check_request, edition: edition, comments: comment)
end

Then /^"([^"]*)" should receive an email requesting fact checking$/ do |email_address|
  Then %{"#{email_address}" should receive an email}
  When %{I open the last email sent to "#{email_address}"}
  Then %{I should see "Fact checking request" in the email subject}
end

Then /^they provide feedback "([^"]*)"$/ do |comments|
  fill_in "Comments", with: comments
  click_button "Submit"
end