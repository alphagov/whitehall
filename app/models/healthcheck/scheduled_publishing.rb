module Healthcheck
  class ScheduledPublishing
    def name
      :scheduled_queue
    end

    def status
      queue_size_matches_edition_count? ? :ok : :warning
    end

    def details
      {
        queue_size: queue_size,
        edition_count: edition_count,
      }
    end

    def message
      "#{edition_count} scheduled edition(s); #{queue_size} job(s) queued"
    end

  private

    def queue_size_matches_edition_count?
      queue_size == edition_count
    end

    def queue_size
      @queue_size ||= ScheduledPublishingWorker.queue_size
    end

    def edition_count
      @edition_count ||= Edition
        .scheduled
        .where(Edition.arel_table[:scheduled_publication].gteq(Time.zone.now))
        .count
    end
  end
end
