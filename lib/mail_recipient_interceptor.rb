class MailRecipientInterceptor
  def self.delivering_email(message)
    body_prefix = "Intended recipient(s): #{message.to.join(', ')}\n\n"

    message.body = body_prefix + message.body.raw_source
    message.to = ENV["EMAIL_ADDRESS_OVERRIDE"]
  end
end
