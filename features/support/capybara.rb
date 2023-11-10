# On the CI box we have seen intermittent failures.
# We think this may be due to timeouts (the default is 2 secs),
# so we've increased the default timeout.
Capybara.default_max_wait_time = 8

# Allow Capybara to click a <label> even if its corresponding <input> isn't visible on screen.
# This needs to be enabled when using custom-styled checkboxes and radios, such as those
# in the GOV.UK Design System.
Capybara.automatic_label_click = true

module ScreenshotHelper
  def screenshot(name = "capybara")
    begin
      page.driver.save_screenshot(Rails.root.join("tmp/#{name}.png"), full: true)
    rescue => error
      puts "Couldn't save a screenshot #{error.message}"
    end
  end
end

World(ScreenshotHelper)
