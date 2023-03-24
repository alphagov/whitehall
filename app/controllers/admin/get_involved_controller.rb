class Admin::GetInvolvedController < Admin::BaseController
  before_action :enforce_permissions!
  layout :get_layout

  def enforce_permissions!
    enforce_permission!(:administer, :get_involved_section)
  end

  def index
    render_design_system("index", "legacy_index", next_release: false)
  end

  def get_layout
    if preview_design_system?(next_release: false)
      "design_system"
    else
      "admin"
    end
  end
end
