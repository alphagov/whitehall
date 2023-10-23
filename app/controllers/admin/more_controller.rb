class Admin::MoreController < Admin::BaseController
  before_action :check_new_design_system_permissions, only: %i[index]
  layout :get_layout

  def index; end

private

  def check_new_design_system_permissions
    forbidden! unless new_design_system?
  end

  def get_layout
    design_system_actions = %w[index] if preview_design_system?(next_release: false)

    if design_system_actions&.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end
end
