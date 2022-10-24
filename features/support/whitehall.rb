Before do
  AttachmentUploader.enable_processing = true
end

module WhitehallHelper
  def using_design_system?
    find("html", class: "govuk-template", wait: false)
    true
  rescue Capybara::ElementNotFound
    false
  end
end

World(WhitehallHelper)
