require "mail_recipient_interceptor"

if ENV.fetch("EMAIL_ADDRESS_OVERRIDE", nil)
  ActionMailer::Base.register_interceptor(MailRecipientInterceptor)
end
