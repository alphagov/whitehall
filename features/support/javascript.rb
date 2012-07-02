Capybara.javascript_driver = :webkit
require "slimmer/test"

Before('@javascript') do
  # ENV["USE_SLIMMER"] = "true"
end

After('@javascript') do
  ENV.delete("USE_SLIMMER")
end
