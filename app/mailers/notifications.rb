class Notifications < ActionMailer::Base
  default from: "fact-check-request@#{Whitehall.domain}"

  def fact_check(policy, to)
    @policy = policy
    
    mail to: to, subject: 'Fact checking request'
  end
end
