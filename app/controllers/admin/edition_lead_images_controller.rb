class Admin::EditionLeadImagesController < Admin::BaseController
  before_action :find_edition, :find_image, :enforce_permissions!
  layout "design_system"

  def update
    edition_lead_image = @edition.edition_lead_image || @edition.build_edition_lead_image
    edition_lead_image.assign_attributes(edition_lead_image_params)

    if updater.can_perform? && edition_lead_image.save!
      updater.perform!
      redirect_to admin_edition_images_path(@edition), notice: "Lead image updated to #{@image.image_data.carrierwave_image}"
    else
      redirect_to admin_edition_images_path(@edition), alert: updater.failure_reason
    end
  end

private

  def find_edition
    edition = Edition.find(params[:edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end

  def find_image
    @image = @edition.images.find(params[:id])
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end

  def edition_lead_image_params
    {
      image_id: @image.id,
      edition_attributes: {
        id: @edition.id,
        image_display_option: "custom_image",
      },
    }
  end

  def updater
    @updater ||= Whitehall.edition_services.draft_updater(@edition)
  end
end
