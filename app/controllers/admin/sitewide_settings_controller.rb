class Admin::SitewideSettingsController < Admin::BaseController
  before_action :enforce_permissions!
  layout :get_layout

  def enforce_permissions!
    enforce_permission!(:administer, :sitewide_settings_section)
  end

  def index
    @sitewide_settings = SitewideSetting.all

    render_design_system("index", "legacy_index", next_release: false)
  end

  def edit
    @sitewide_setting = SitewideSetting.find(params[:id])

    render_design_system("edit", "legacy_edit", next_release: false)
  end

  def update
    @sitewide_setting = SitewideSetting.find(params[:id])
    if @sitewide_setting.update(sitewide_settings_params)
      redirect_to admin_sitewide_settings_path, notice: %("#{@sitewide_setting.name}" updated.)
    else
      render_design_system("edit", "legacy_edit", next_release: false)
    end
  end

private

  def get_layout
    if preview_design_system?(next_release: false)
      "design_system"
    else
      "admin"
    end
  end

  def sitewide_settings_params
    params.require(:sitewide_setting).permit(:on, :govspeak)
  end
end
