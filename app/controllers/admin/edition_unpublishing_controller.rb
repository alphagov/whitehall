class Admin::EditionUnpublishingController < Admin::BaseController
  before_filter :load_unpublishing
  before_filter :enforce_permissions!

  def update
    if @unpublishing.update_attributes(explanation: params[:unpublishing][:explanation])
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

end
