require "govuk_app_config/govuk_prometheus_exporter"
require "collectors/scheduled_publishing_collector"

GovukPrometheusExporter.configure(collectors: [Collectors::ScheduledPublishingCollector])
