# On the CI box we have seen intermittent failures.
# We think this may be due to timeouts (the default is 2 secs),
# so we've increased the default timeout.
Capybara.default_max_wait_time = 5

# Allow Capybara to click a <label> even if its corresponding <input> isn't visible on screen.
# This needs to be enabled when using custom-styled checkboxes and radios, such as those
# in the GOV.UK Design System.
Capybara.automatic_label_click = true

Capybara.register_driver :headless_chrome do |app|
  chrome_options = GovukTest.headless_chrome_selenium_options
  chrome_options.add_argument("--no-sandbox")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: chrome_options,
  )
end

module ScreenshotHelper
  def screenshot(name = "capybara")
    page.driver.render(Rails.root.join("tmp/#{name}.png"), full: true)
  end
end

World(ScreenshotHelper)
