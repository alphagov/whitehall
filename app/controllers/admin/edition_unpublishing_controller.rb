class Admin::EditionUnpublishingController < Admin::BaseController
  before_action :load_unpublishing
  before_action :enforce_permissions!

  def update
    services = Whitehall.edition_services
    if @unpublishing.update_attributes(explanation: params[:unpublishing][:explanation])
      if withdrawing?
        services.withdrawer(@unpublishing.edition, user: current_user).perform!
      else
        services.unpublisher(@unpublishing.edition).perform!
      end
      redirect_to admin_edition_path(@unpublishing.edition), notice: "The public explanation was updated"
    else
      flash.now[:alert] = "The public explanation could not be updated"
      render :edit
    end
  end

private

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
