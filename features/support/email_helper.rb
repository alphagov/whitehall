module EmailHelper
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

World(EmailHelper)