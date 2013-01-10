class Admin::WorldwideOfficesController < Admin::BaseController
  respond_to :html

  def index
    respond_with @worldwide_offices = WorldwideOffice.all
  end

  def new
    respond_with @worldwide_office = WorldwideOffice.new
  end

  def create
    @worldwide_office = WorldwideOffice.new(params[:worldwide_office])
    @worldwide_office.save
    respond_with @worldwide_office, location: admin_worldwide_offices_path
  end

  def edit
    respond_with @worldwide_office = WorldwideOffice.find(params[:id])
  end

  def update
    @worldwide_office = WorldwideOffice.find(params[:id])
    @worldwide_office.update_attributes(params[:worldwide_office])
    respond_with @worldwide_office, location: admin_worldwide_offices_path
  end

  def destroy
    @worldwide_office = WorldwideOffice.find(params[:id])
    @worldwide_office.destroy
    respond_with @worldwide_office, location: admin_worldwide_offices_path
  end
end
