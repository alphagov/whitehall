class Admin::NeedsController < Admin::BaseController
  before_action :find_latest_edition
  layout "design_system"

  def edit; end

  def update
    @document.need_ids = params[:need_ids] || []
    @document.patch_meets_user_needs_links

    redirect_to admin_edition_path(@edition)
  end

private

  def find_latest_edition
    @document = Document.find_by(content_id: params[:content_id])
    @edition = @document.latest_edition
  end
end
