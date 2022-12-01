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

  def within_conditional_reveal(label, &block)
    input = find_field(label)
    conditional_reveal_id = input["aria-controls"] || input["data-aria-controls"]
    conditional_reveal = find_by_id(conditional_reveal_id)
    within(conditional_reveal, &block)
  end
end

World(DesignSystemHelper)
