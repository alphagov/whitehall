class HealthcheckController < ActionController::API
  def overdue
    render json: { overdue: Edition.due_for_publication.count }
  end
end
