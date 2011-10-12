require File.expand_path('production.rb', File.dirname(__FILE__))

Whitehall::Application.configure do
  # Prevent `ActionView::Template::Error (application.css isn't precompiled)` on staging
  config.assets.compile = true

  # Prevent `OpenSSL::SSL::SSLError (hostname was not match with the server certificate)` on staging
  config.action_mailer.smtp_settings = {enable_starttls_auto: false}
end