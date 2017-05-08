class Admin::SitewideSettingsController <  Admin::BaseController
  before_action :enforce_permissions!

  def enforce_permissions!
    enforce_permission!(:administer, :sitewide_settings_section)
  end

  def index
    @sitewide_settings = SitewideSetting.all
  end

  def edit
    @sitewide_setting = SitewideSetting.find(params[:id])
  end

  def update
    @sitewide_setting = SitewideSetting.find(params[:id])
    if @sitewide_setting.update_attributes(sitewide_settings_params)
      redirect_to admin_sitewide_settings_path, notice: %{"#{@sitewide_setting.name}" updated.}
    else
      render action: "edit"
    end
  end

  private

  def sitewide_settings_params
    params.require(:sitewide_setting).permit(:on, :govspeak)
  end
end
