class Admin::WorldwideOrganisationsController < Admin::BaseController
  respond_to :html

  before_filter :find_worldwide_organisation, except: [:index, :new, :create]

  def index
    respond_with @worldwide_organisations = WorldwideOrganisation.all
  end

  def new
    @worldwide_organisation = WorldwideOrganisation.new
    respond_with :admin, @worldwide_organisation
  end

  def create
    @worldwide_organisation = WorldwideOrganisation.create(params[:worldwide_organisation])
    respond_with :admin, @worldwide_organisation
  end

  def edit
    respond_with :admin, @worldwide_organisation
  end

  def update
    @worldwide_organisation.update_attributes(params[:worldwide_organisation])
    respond_with :admin, @worldwide_organisation
  end

  def set_main_contact
    if @worldwide_organisation.update_attributes(params[:worldwide_organisation])
      flash[:notice] = "Main contact updated successfully"
    end
    respond_with :contacts, :admin, @worldwide_organisation
  end

  def destroy
    @worldwide_organisation.destroy
    respond_with :admin, @worldwide_organisation
  end

  private

  def find_worldwide_organisation
    @worldwide_organisation = WorldwideOrganisation.find(params[:id])
  end
end
