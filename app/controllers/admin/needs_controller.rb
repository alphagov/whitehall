class Admin::NeedsController < Admin::BaseController
  before_action :find_latest_edition
  layout :get_layout

  def edit
    render_design_system("edit", "edit_legacy", next_release: false)
  end

  def update
    @document.need_ids = params[:need_ids] || []
    @document.patch_meets_user_needs_links

    redirect_to admin_edition_path(@edition)
  end

private

  def get_layout
    if preview_design_system?(next_release: false)
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
