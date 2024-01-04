module Collectors
  class ScheduledPublishingOverdueCollector < PrometheusExporter::Server::CollectorBase
    def type
      "whitehall"
    end

    def metrics
      whitehall_scheduled_publishing_overdue = PrometheusExporter::Metric::Gauge.new("whitehall_scheduled_publishing_overdue", "Overdue scheduled publications")
      whitehall_scheduled_publishing_overdue.observe(Edition.due_for_publication.count)

      [whitehall_scheduled_publishing_overdue]
    end
  end
end
