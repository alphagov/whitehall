# static.preview SSL certificate is causing errors in Cucumber tests,
# so we're ignoring SSL errors for now.
Capybara.register_driver :webkit do |app|
  Capybara::Driver::Webkit.new(app, ignore_ssl_errors: true)
end

Capybara.javascript_driver = :webkit
require "slimmer/test"

Before('@javascript') do
  ENV["USE_SLIMMER"] = "true"
end

After('@javascript') do
  ENV.delete("USE_SLIMMER")
end
