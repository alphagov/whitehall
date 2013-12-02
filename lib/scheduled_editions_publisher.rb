class ScheduledEditionsPublisher
  class PublishingFailure < StandardError
    attr_reader :unpublished_edition_ids

    def initialize(msg, unpublished_edition_ids)
      @unpublished_edition_ids = unpublished_edition_ids
      super(msg)
    end
  end

  attr_reader :log_cache

  def initialize(editions_scope)
    unless editions_scope.is_a?(ActiveRecord::Relation)
      raise ArgumentError, 'editions_scope must be an ActiveRecord::Relation'
    end
    @editions_scope = editions_scope
    @log_cache = ''
  end

  def editions
    @editions_scope.reload.to_ary
  end

  def publish_all!
    reset_attempt_count
    Whitehall.stats_collector.increment("scheduled_publishing.call_rate")

    while unpublished_editions_remaining?
      raise PublishingFailure.new(log_cache, editions.collect(&:id)) if attempt_limit_reached?
      log_publish_run do
        editions.each { |edition| publish_edition!(edition) }
      end
      increment_attempt_count
    end
  end

  def publish_edition!(edition)
    Whitehall::Wait.until edition.scheduled_publication do
      EditionPublishingWorker.new.perform(edition.id, publishing_robot.id)
      log_successful_publication(edition)
    end
  rescue Exception => exception
    log_unsuccessful_publication(edition, exception.message)
  end

  def publishing_robot
    User.where(name: "Scheduled Publishing Robot", uid: nil).first
  end

  def self.publish_all_due_editions
    editions_scope = Edition.due_for_publication(5.minutes).order("scheduled_publication asc")
    new(editions_scope).publish_all!
  end

  def log(message)
    Rails.logger.info("Scheduled Publisher > #{message}")
    @log_cache << message << "\n"
  end

  private

  def unpublished_editions_remaining?
    unpublished_editions_count > 0
  end

  def unpublished_editions_count
    @editions_scope.count
  end

  def reset_attempt_count
    @attempts = 0
  end
  def attempt_limit_reached?
    @attempts >= 5
  end

  def increment_attempt_count
    @attempts +=1
  end

  def log_publish_run(&block)
    log "Starting attempt No. #{@attempts}"
    log "Time now: #{Time.zone.now}"
    log "Detected #{unpublished_editions_count} editions due to be published:"
    editions.each {|e| log "\t#{e.id} - #{e.title} - due at #{e.scheduled_publication}" }

    yield

    log "Finishing attempt No. #{@attempts}"
    log "WARNING: #{unpublished_editions_count} unpublished editions still remain" if unpublished_editions_remaining?
  end

  def log_successful_publication(edition)
    log "Edition (#{edition.id}) successfully published at #{Time.zone.now}"
    Whitehall.stats_collector.increment('scheduled_publishing.published')
  end

  def log_unsuccessful_publication(edition, reason)
    log "WARNING: Edition (#{edition.id}) failed to publish: #{reason}"
  end
end
