class Notifications < ActionMailer::Base
  def fact_check(fact_check_request, requester, url_options)
    @fact_check_request = fact_check_request
    @url_options = url_options
    @requester = requester

    mail from: "fact-check-request@#{url_options[:host]}",
         to: @fact_check_request.email_address,
         subject: "Fact checking request from #{requester.name}"
  end
end
