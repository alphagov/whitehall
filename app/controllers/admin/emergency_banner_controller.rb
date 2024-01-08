class Admin::EmergencyBannerController < Admin::BaseController
  before_action :enforce_permissions!
  before_action :load_current_banner

  def enforce_permissions!
    enforce_permission!(:administer, :emergency_banner)
  end

  def show; end

  def edit
    @errors = {}
  end

  def update
    if emergency_banner_params[:campaign_class].present? && emergency_banner_params[:heading].present?
      redis_client.hmset(
        :emergency_banner,
        :campaign_class,
        emergency_banner_params[:campaign_class],
        :heading,
        emergency_banner_params[:heading],
        :short_description,
        emergency_banner_params[:short_description],
        :link,
        emergency_banner_params[:link],
        :link_text,
        emergency_banner_params[:link_text],
      )

      redirect_to admin_emergency_banner_path, notice: "Emergency banner updated sucessfully"
    else
      @errors = {}
      @errors[:campaign_class] = I18n.t("emergency_banner.errors.campaign_class") if emergency_banner_params[:campaign_class].blank?
      @errors[:heading] = I18n.t("emergency_banner.errors.heading") if emergency_banner_params[:heading].blank?

      render :edit
    end
  end

private

  def emergency_banner_params
    params.fetch(:emergency_banner, {}).permit(
      :campaign_class,
      :heading,
      :short_description,
      :link,
      :link_text,
    )
  end

  def load_current_banner
    @current_banner = redis_client.hgetall("emergency_banner").try(:symbolize_keys)
  end

  def redis_client
    Redis.new
  end
end
