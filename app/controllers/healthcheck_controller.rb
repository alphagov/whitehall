class HealthcheckController < ActionController::API
  def overdue
    render json: { overdue: Edition.due_for_publication.count }
  rescue ActiveRecord::StatementInvalid => e
    logger.error "HealthcheckController#overdue: #{e.message}"
    render json: { overdue: nil }, status: :service_unavailable
  end

  def unenqueued_scheduled_editions
    render json: {
      unenqueued_scheduled_editions: Edition.future_scheduled_editions.count - ScheduledPublishingWorker.queue_size,
    }
  rescue ActiveRecord::StatementInvalid => e
    logger.error "HealthcheckController#unenqueued_scheduled_editions: #{e.message}"
    render json: { unenqueued_scheduled_editions: nil }, status: :service_unavailable
  end
end
