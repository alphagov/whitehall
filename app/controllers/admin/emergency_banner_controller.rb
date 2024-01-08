class Admin::EmergencyBannerController < Admin::BaseController
  before_action :enforce_permissions!

  def enforce_permissions!
    enforce_permission!(:administer, :emergency_banner)
  end

  def show
    @current_banner = redis_client.hgetall("emergency_banner").try(:symbolize_keys)
  end

private

  def redis_client
    Redis.new
  end
end
