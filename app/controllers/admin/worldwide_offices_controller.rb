class Admin::WorldwideOfficesController < Admin::BaseController
  respond_to :html

  before_filter :find_worldwide_office, only: [:edit, :update, :destroy, :show, :contacts, :set_main_contact, :social_media_accounts]

  def index
    respond_with @worldwide_offices = WorldwideOffice.all
  end

  def new
    @worldwide_office = WorldwideOffice.new
    respond_with :admin, @worldwide_office
  end

  def create
    @worldwide_office = WorldwideOffice.create(params[:worldwide_office])
    respond_with :admin, @worldwide_office
  end

  def edit
    respond_with :admin, @worldwide_office
  end

  def update
    @worldwide_office.update_attributes(params[:worldwide_office])
    respond_with :admin, @worldwide_office
  end

  def set_main_contact
    if @worldwide_office.update_attributes(params[:worldwide_office])
      flash[:notice] = "Main contact updated successfully"
    end
    respond_with :contacts, :admin, @worldwide_office
  end

  def destroy
    @worldwide_office.destroy
    respond_with :admin, @worldwide_office
  end

  private

  def find_worldwide_office
    @worldwide_office = WorldwideOffice.find(params[:id])
  end
end
