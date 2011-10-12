class Notifications < ActionMailer::Base
  def fact_check(fact_check_request, url_options)
    @fact_check_request = fact_check_request
    @url_options = url_options

    mail from: "fact-check-request@#{url_options[:host]}",
         to: @fact_check_request.email_address,
         subject: "Fact checking request"
  end
end
