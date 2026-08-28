class Admin::EditionUnpublishingController < Admin::BaseController
  before_action :load_unpublishing
  before_action :enforce_permissions!

  def edit; end

  def update
    ActiveRecord::Base.transaction do
      services = Whitehall.edition_services
      if @unpublishing.update(unpublishing_params)
        if withdrawing?
          services.withdrawer(@unpublishing.edition, user: current_user).perform!
        else
          services.unpublisher(@unpublishing.edition).perform!
        end
        redirect_to admin_edition_path(@unpublishing.edition), {
          notice: "The #{helpers.withdrawal_or_unpublishing(@unpublishing.edition)} was updated",
        }
      else
        render :edit
      end
    end
  rescue GdsApi::HTTPUnprocessableEntity
    flash.now[:alert] = "Error: Publishing API rejected the redirect"
    render :edit, status: :unprocessable_entity
  end

private

  def unpublishing_params
    params.expect(unpublishing: %i[alternative_url explanation redirect])
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
