class Notifications < ActionMailer::Base
  default from: "fact-check-request@#{Whitehall.domain}"

  def fact_check(fact_check_request)
    @edition = fact_check_request.edition
    @fact_check_request = fact_check_request

    mail to: @fact_check_request.email_address,
         subject: 'Fact checking request'
  end
end
