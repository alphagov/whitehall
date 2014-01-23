class Admin::AccessAndOpeningTimesController < Admin::BaseController
  before_filter :load_accessible
  helper_method :accessible_path

  def edit
    @access_and_opening_times = @accessible.access_and_opening_times || @accessible.build_access_and_opening_times
    set_default_body_for_worldwide_office
  end

  def create
    @access_and_opening_times = @accessible.build_access_and_opening_times(access_and_opening_times_params)
    if @access_and_opening_times.save
      redirect_to accessible_path(@accessible), notice: 'Access information saved.'
    else
      render :edit
    end
  end

  def update
    @access_and_opening_times = @accessible.access_and_opening_times
    if @access_and_opening_times.update_attributes(access_and_opening_times_params)
      redirect_to accessible_path(@accessible), notice: 'Access information saved.'
    else
      render :edit
    end
  end

  private

  def load_accessible
    @worldwide_organisation = WorldwideOrganisation.find(params[:worldwide_organisation_id])
    if params[:worldwide_office_id]
      @accessible = @worldwide_organisation.offices.find(params[:worldwide_office_id])
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

  def set_default_body_for_worldwide_office
    if @accessible.is_a?(WorldwideOffice)
      @access_and_opening_times.body ||= @accessible.default_access_and_opening_times.try(:body)
    end
  end

  def access_and_opening_times_params
    params.require(:access_and_opening_times).permit(:body)
  end
end
