require File.expand_path('production.rb', File.dirname(__FILE__))

Whitehall::Application.configure do
  # Prevent `OpenSSL::SSL::SSLError (hostname was not match with the server certificate)` on staging
  config.action_mailer.smtp_settings = {enable_starttls_auto: false}
end