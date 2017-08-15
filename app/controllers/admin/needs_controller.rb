class Admin::NeedsController < Admin::BaseController
  def edit
    @document = Document.find_by(content_id: params[:content_id])
    @edition = @document.latest_edition
  end

  def update
    document = Document.find_by(content_id: params[:content_id])
    edition = document.latest_edition

    document.need_ids = params[:need_ids] || []
    document.patch_meets_user_needs_links

    redirect_to admin_edition_path(edition)
  end
end
