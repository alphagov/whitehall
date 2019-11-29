class HealthcheckController < ActionController::API
  def overdue
    render json: { overdue: Edition.due_for_publication.count }
  rescue ActiveRecord::StatementInvalid => e
    logger.error "HealthcheckController#overdue: #{e.message}"
    render json: { overdue: nil }, status: :service_unavailable
  end
end
