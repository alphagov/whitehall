class ScheduledEditionsPublisher
  def self.publish_all_due_editions
    editions_scope = Edition.due_for_publication(5.minutes).order("scheduled_publication asc")
    new(editions_scope).publish_all!
  end

  def initialize(editions_scope)
    unless editions_scope.is_a?(ActiveRecord::Relation)
      raise ArgumentError, 'editions_scope must be an ActiveRecord::Relation'
    end
    @editions_scope = editions_scope
  end

  def editions
    @editions_scope.reload.to_ary
  end

  def unpublished_editions_count
    @editions_scope.count
  end

  def publish_all!
    log_publish_run do
      editions.each { |edition| publish_edition!(edition) }
    end
  end

  def publish_edition!(edition)
    wait_until edition.scheduled_publication do
      EditionPublishingWorker.new.perform(edition.id, publishing_robot.id)
      log_successful_publication(edition)
    end
  rescue Object => exception
    log_unsuccessful_publication(edition, exception.message)
  end

  def publishing_robot
    User.where(name: "Scheduled Publishing Robot", uid: nil).first
  end

  private

  def wait_until(timestamp, &block)
    while Time.zone.now < timestamp
      time_to_wait = timestamp - Time.zone.now
      log "Waiting #{time_to_wait} seconds until #{timestamp}. Time now is #{Time.zone.now}"
      sleep(time_to_wait)
    end
    yield
  end

  def log(message)
    Rails.logger.info(message)
  end

  def log_publish_run(&block)
    Whitehall.stats_collector.increment("scheduled_publishing.call_rate")
    log "SCHEDULED PUBLISHING"
    log "Time now: #{Time.zone.now}"
    log "Detected #{unpublished_editions_count} editions to publish:"
    editions.each {|e| log "#{e.id} - #{e.title} - due at #{e.scheduled_publication}" }

    yield

    log "SCHEDULED PUBLISHING COMPLETE"
  end

  def log_successful_publication(edition)
    log "Edition (#{edition.id}) successfully published"
    Whitehall.stats_collector.increment('scheduled_publishing.published')
  end

  def log_unsuccessful_publication(edition, reason)
    log "Unable to publish edition (#{edition.id}): #{reason}"
  end
end
