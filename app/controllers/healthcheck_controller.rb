class HealthcheckController < ActionController::Base
  def check
    # Check database connectivity
    Edition.count
    render json: {}
  end
  def overdue
    # Check the number of overdue editions
    render json: { 'overdue' => Edition.due_for_publication.count }
  end
end
