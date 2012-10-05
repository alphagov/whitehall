class HealthcheckController < ActionController::Base
  def check
    # Check database connectivity
    Edition.count
    render json: {}
  end
end
