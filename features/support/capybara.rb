# On the CI box we have seen intermittent failures.
# We think this may be due to timeouts (the default is 2 secs),
# so we've increased the default timeout.
Capybara.default_max_wait_time = 5

# Allow Capybara to click a <label> even if its corresponding <input> isn't visible on screen.
# This needs to be enabled when using custom-styled checkboxes and radios, such as those
# in the GOV.UK Design System.
Capybara.automatic_label_click = true

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(app,
                                   browser_type: :chromium,
                                   headless: true)
end

Capybara.configure do |config|
  config.asset_host = ENV.fetch("ASSET_HOST", nil)
end

Capybara.javascript_driver = :playwright
