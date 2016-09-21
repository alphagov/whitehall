class OperationalFieldsController < PublicFacingController
  def index
    @operational_fields = OperationalField.all
  end

  def show
    @operational_field = OperationalField.friendly.find(params[:id])
    @organisation = Organisation.where(handles_fatalities: true).first
    set_meta_description("Details about British fatalities for operations in #{@operational_field.name}.")
    set_slimmer_organisations_header([@organisation])
    set_slimmer_page_owner_header(@organisation)
    @fatality_notices = @operational_field.published_fatality_notices.order('first_published_at desc').map do |fatality_notice|
      FatalityNoticePresenter.new(fatality_notice)
    end
  end
end
