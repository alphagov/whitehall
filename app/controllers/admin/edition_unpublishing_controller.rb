class Admin::EditionUnpublishingController < Admin::BaseController
  layout :get_layout
  before_action :load_unpublishing
  before_action :enforce_permissions!

  def edit
    render_design_system("edit", "edit_legacy", next_release: true)
  end

  def update
    services = Whitehall.edition_services
    if @unpublishing.update(explanation: params[:unpublishing][:explanation])
      if withdrawing?
        services.withdrawer(@unpublishing.edition, user: current_user).perform!
      else
        services.unpublisher(@unpublishing.edition).perform!
      end
      redirect_to admin_edition_path(@unpublishing.edition), notice: "The public explanation was updated"
    else
      flash.now[:alert] = "The public explanation could not be updated" unless preview_design_system?(next_release: true)
      render_design_system("edit", "edit_legacy", next_release: true)
    end
  end

private

  def get_layout
    preview_design_system?(next_release: true) ? "design_system" : "admin"
  end

  def load_unpublishing
    @unpublishing = Edition.find(params[:edition_id]).unpublishing
  end

  def enforce_permissions!
    enforce_permission!(:unpublish, @unpublishing.edition)
  end

  def withdrawing?
    @unpublishing.unpublishing_reason_id == UnpublishingReason::Withdrawn.id
  end
end
