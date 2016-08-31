class Admin::EditionUnpublishingController < Admin::BaseController
  before_filter :load_unpublishing
  before_filter :enforce_permissions!

  def update
    if @unpublishing.update_attributes(explanation: params[:unpublishing][:explanation])
      if withdrawing?
        content_id = @unpublishing.edition.content_id
        Whitehall::PublishingApi.publish_withdrawal_async(content_id, @unpublishing.explanation)
      else
        Whitehall::PublishingApi.unpublish_async(@unpublishing)
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
