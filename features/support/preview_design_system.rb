if ENV["CUCUMBER_PREVIEW_DESIGN_SYSTEM"] == "true"
  Before do
    # Enable 'Preview design system' flag
    Admin::BaseController.any_instance.stubs(:preview_design_system?).returns(true)
  end
end

module DesignSystemHelper
  def using_design_system?
    ENV["CUCUMBER_PREVIEW_DESIGN_SYSTEM"] == "true"
  end
end

World(DesignSystemHelper)
