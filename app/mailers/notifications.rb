class Notifications < ActionMailer::Base
  default from: "fact-check-request@#{Whitehall.domain}"

  def fact_check(edition, to)
    @edition = edition
    @fact_check_request = @edition.fact_check_requests.create!
    
    mail to: to, subject: 'Fact checking request'
  end
end
