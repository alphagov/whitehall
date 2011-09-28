Then /^"([^"]*)" should receive an email requesting fact checking$/ do |email_address|
  Then %{"#{email_address}" should receive an email}
  When %{I open the last email sent to "#{email_address}"}
  Then %{I should see "Fact checking request" in the email subject}
end