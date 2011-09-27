require File.expand_path('production.rb', File.dirname(__FILE__))

Whitehall::Application.configure do
  # Compile assets on the fly if they're missing on staging
  config.assets.compile = true

  config.whitehall.host = 'whitehall.staging.alphagov.co.uk:8080'
end