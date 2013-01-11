class Admin::WorldwideOfficesController < Admin::BaseController
  respond_to :html

  before_filter :social_media, only: [:new, :create, :edit, :update]
  attr :social

  def index
    respond_with @worldwide_offices = WorldwideOffice.all
  end

  def new
    @worldwide_office = WorldwideOffice.new
    social.build_social_media_account(@worldwide_office)
    respond_with @worldwide_office
  end

  def create
    social.destroy_blank_social_media_accounts(params[:worldwide_office])
    @worldwide_office = WorldwideOffice.new(params[:worldwide_office])

    unless @worldwide_office.save
      social.build_social_media_account(@worldwide_office)
    end

    respond_with @worldwide_office, location: admin_worldwide_offices_path
  end

  def edit
    @worldwide_office = WorldwideOffice.find(params[:id])
    social.build_social_media_account(@worldwide_office)
    respond_with @worldwide_office
  end

  def update
    social.destroy_blank_social_media_accounts(params[:worldwide_office])
    @worldwide_office = WorldwideOffice.find(params[:id])

    unless @worldwide_office.update_attributes(params[:worldwide_office])
      social.build_social_media_account(@worldwide_office)
    end

    respond_with @worldwide_office, location: admin_worldwide_offices_path
  end

  def destroy
    @worldwide_office = WorldwideOffice.find(params[:id])
    @worldwide_office.destroy
    respond_with @worldwide_office, location: admin_worldwide_offices_path
  end

  private

  def social_media
    @social = Whitehall::Controllers::SocialMedia.new
  end
end
