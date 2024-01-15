module Collectors
  class ScheduledPublishingCollector < PrometheusExporter::Server::CollectorBase
    def type
      "whitehall"
    end

    def metrics
      whitehall_scheduled_publishing_overdue = PrometheusExporter::Metric::Gauge.new("whitehall_scheduled_publishing_overdue", "Overdue scheduled publications")
      whitehall_scheduled_publishing_overdue.observe(Edition.due_for_publication.count)

      whitehall_unenqueued_scheduled_publications = PrometheusExporter::Metric::Gauge.new("whitehall_unenqueued_scheduled_publications", "Unenqueued scheduled publications")
      whitehall_unenqueued_scheduled_publications.observe(Edition.future_scheduled_editions.count - ScheduledPublishingWorker.queue_size)

      [
        whitehall_scheduled_publishing_overdue,
        whitehall_unenqueued_scheduled_publications,
      ]
    end
  end
end
