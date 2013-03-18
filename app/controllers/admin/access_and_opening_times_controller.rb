class Admin::AccessAndOpeningTimesController < Admin::BaseController
  before_filter :load_accessible

  def new
    @access_and_opening_times = @accessible.build_access_and_opening_times
  end

  def create
    @access_and_opening_times = @accessible.build_access_and_opening_times(params[:access_and_opening_times])
    if @access_and_opening_times.save
      redirect_to [:access_info, :admin, @accessible], notice: 'Access information saved.'
    else
      render :new
    end
  end

  def update
    @access_and_opening_times = @accessible.access_and_opening_times
    if @access_and_opening_times.update_attributes(params[:access_and_opening_times])
      redirect_to [:access_info, :admin, @accessible], notice: 'Access information updated.'
    else
      render :edit
    end
  end

  def edit
    @access_and_opening_times = @accessible.access_and_opening_times
  end

  def load_accessible
    @accessible = WorldwideOrganisation.find(params[:worldwide_organisation_id])
  end
end
