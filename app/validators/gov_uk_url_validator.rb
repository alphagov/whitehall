#Accepts options[:message] and options[:allowed_protocols]
class GovUkUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value !~ %r(\A#{Whitehall.public_protocol}://#{Whitehall.public_host}/)
      record.errors[attribute] << failure_message
    end
  end

private

  def failure_message
    options[:message] || "must be in the form of #{Whitehall.public_protocol}://#{Whitehall.public_host}/example"
  end
end
