class HealthcheckController < ActionController::Base
  def check
    render json: {
      checks: {
        scheduled_queue: scheduled_queue_status_hash,
      },
      status: overall_status
    }
  end

  def overdue
    # Check the number of overdue editions
    render json: {
      'overdue' => Edition.due_for_publication.count,
      'missing_from_site' => [],
    }
  end

private

  def overall_status
    queued_job_count_matches_scheduled_editions? ? 'ok' : 'warning'
  end

  def scheduled_queue_status_hash
    status = queued_job_count_matches_scheduled_editions? ? 'ok' : 'warning'
    { status: status }.tap do |status_hash|
      status_hash[:message] = "#{scheduled_edition_count} scheduled edition(s); #{scheduled_queue_size} job(s) queued"
    end
  end

  def queued_job_count_matches_scheduled_editions?
    scheduled_queue_size == scheduled_edition_count
  end

  def scheduled_queue_size
    ScheduledPublishingWorker.queue_size
  end

  def scheduled_edition_count
    Edition.scheduled.where(Edition.arel_table[:scheduled_publication].gteq(Time.zone.now)).count
  end
end
