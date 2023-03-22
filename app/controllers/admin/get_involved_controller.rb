class Admin::GetInvolvedController < Admin::BaseController
  before_action :enforce_permissions!
  layout :get_layout

  def enforce_permissions!
    enforce_permission!(:administer, :get_involved_section)
  end

  def index; end

  def get_layout
    design_system_actions = []
    design_system_actions += %w[] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end
end
