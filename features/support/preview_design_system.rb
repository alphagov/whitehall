if ENV["CUCUMBER_PREVIEW_DESIGN_SYSTEM"] == "true"
  Before do
    # Enable 'Preview next release' flag by stubbing the user permission
    User.any_instance.stubs(:can_preview_next_release?).returns(true)
  end
end

module DesignSystemHelper
  def using_design_system?
    find("html", class: "govuk-template", wait: false)
    true
  rescue Capybara::ElementNotFound
    false
  end
end

World(DesignSystemHelper)
