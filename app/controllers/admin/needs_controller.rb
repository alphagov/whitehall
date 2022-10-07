class Admin::NeedsController < Admin::BaseController
  before_action :find_latest_edition
  before_action :forbid_editing_of_locked_documents
  layout :get_layout

  def edit
    render(preview_design_system_user? ? "edit" : "edit_legacy")
  end

  def update
    @document.need_ids = params[:need_ids] || []
    @document.patch_meets_user_needs_links

    redirect_to admin_edition_path(@edition)
  end

private

  def get_layout
    return "admin" unless preview_design_system_user?

    case action_name
    when "edit"
      "design_system"
    else
      "admin"
    end
  end

  def find_latest_edition
    @document = Document.find_by(content_id: params[:content_id])
    @edition = @document.latest_edition
  end
end
