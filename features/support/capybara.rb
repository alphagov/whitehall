# On the CI box we have seen intermittent failures.
# We think this may be due to timeouts (the default is 2 secs),
# so we've increased the default timeout.
Capybara.default_wait_time = 5

module ScreenshotHelper
  def screenshot(name = 'capybara')
    page.driver.render(File.join(Rails.root, 'tmp', "#{name}.png"), full: true)
  end
end

World(ScreenshotHelper)
