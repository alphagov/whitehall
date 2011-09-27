require File.expand_path('production.rb', File.dirname(__FILE__))

Whitehall::Application.configure do
  config.whitehall.host = 'whitehall.staging.alphagov.co.uk:8080'
end