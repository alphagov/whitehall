module EmailHelpers
  def emails_for(address)
    ActionMailer::Base.deliveries.select do |d|
      d.to.include?(address)
    end
  end
  def read_emails_for(address)
    read_emails[address] ||= []
  end
  def unread_emails_for(address)
    emails_for(address) - read_emails_for(address)
  end
  def read_emails
    @read_emails ||= {}
  end
end

World(EmailHelpers)

Then /^"([^"]*?)" should receive an email$/ do |address|
  assert_equal 1, unread_emails_for(address).size
end

When /^(?:I open|an admin opens) the last email sent to "([^"]*)"$/ do |address|
  @current_email = emails_for(address).last
  read_emails_for(address) << @current_email
end

Then /^(?:I|they) should see "([^"]*)" in the email subject$/ do |subject|
  assert_equal subject, @current_email.subject
end

Then /^(?:I|they) should see "([^"]*)" in the email body$/ do |body|
  assert_match Regexp.new(body), @current_email.body.to_s
end

When /^I click the first link in the email$/ do
  links = URI.extract(@current_email.body.to_s, ["http", "https"])
  visit links.first
end