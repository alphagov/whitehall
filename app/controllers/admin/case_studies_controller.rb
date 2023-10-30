class Admin::CaseStudiesController < Admin::EditionsController
  def edition_class
    CaseStudy
  end

  def update_image_display_option
    @edition.assign_attributes(image_display_option_params)

    if updater.can_perform? && @edition.save_as(current_user)
      @edition.update_lead_image
      updater.perform!

      redirect_to admin_edition_images_path(@edition), notice: "The lead image has been updated"
    else
      redirect_to admin_edition_images_path(@edition), alert: updater.failure_reason
    end
  end

private

  def image_display_option_params
    params
    .require(:edition)
    .permit(:image_display_option)
  end
end
