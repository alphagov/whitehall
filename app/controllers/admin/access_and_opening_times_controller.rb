class Admin::AccessAndOpeningTimesController < Admin::BaseController
  before_action :load_accessible
  helper_method :accessible_path

  def edit
    @access_and_opening_times = AccessAndOpeningTimesForm.new({ body: @accessible.access_and_opening_times })
  end

  def update
    @access_and_opening_times = AccessAndOpeningTimesForm.new(access_and_opening_times_params)
    if @access_and_opening_times.save(@accessible)
      redirect_to accessible_path(@accessible), notice: "Access information saved."
    else
      render :edit
    end
  end

private

  def load_accessible
    @worldwide_organisation = WorldwideOrganisation.friendly.find(params[:worldwide_organisation_id])
    if params[:worldwide_office_id]
      @accessible = @worldwide_organisation.offices.friendly.find(params[:worldwide_office_id])
      @accessible_name = @accessible.title
    else
      @accessible = @worldwide_organisation
      @accessible_name = @worldwide_organisation.name
    end
  end

  def accessible_path(accessible)
    case accessible
    when WorldwideOrganisation
      [:access_info, :admin, accessible]
    when WorldwideOffice
      [:admin, accessible.worldwide_organisation, WorldwideOffice]
    end
  end

  def access_and_opening_times_params
    params.require(:access_and_opening_times_form).permit(:body)
  end
end
