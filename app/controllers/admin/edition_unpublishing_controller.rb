class Admin::EditionUnpublishingController < Admin::BaseController
  layout :get_layout
  before_action :load_unpublishing
  before_action :enforce_permissions!

  def edit
    render "edit_legacy" unless preview_design_system_user?
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
    elsif preview_design_system_user?
      render "edit"
    else
      flash.now[:alert] = "The public explanation could not be updated"
      render "edit_legacy"
    end
  end

private

  def get_layout
    return "admin" unless preview_design_system_user?

    case action_name
    when "edit", "update", "new"
      "design_system"
    else
      "admin"
    end
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
