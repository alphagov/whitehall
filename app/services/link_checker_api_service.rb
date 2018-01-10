class LinkCheckerApiService
  def self.has_links?(reportable)
    extract_links(reportable).count > 0
  end

  def self.extract_links(reportable)
    Govspeak::LinkExtractor.new(reportable.body).links
  end

  def self.check_links(reportable, webhook_uri)
    uris = extract_links(reportable)
    raise "Reportable has no links to check" unless uris.count > 0

    Rails.logger.info "Checking links for #{reportable} which has #{uris.count} URIs, including: #{uris[0]}"

    batch_report = Whitehall.link_checker_api_client.create_batch(
      uris,
      webhook_uri: webhook_uri,
      webhook_secret_token: webhook_secret_token
    )

    batch_report_id = batch_report.fetch('id')

    Rails.logger.info "Batch for Edition #{reportable.id} with id #{batch_report_id}"

    existing_report = LinkCheckerApiReport.find_by(batch_id: batch_report_id)

    if existing_report
      Rails.logger.info "LinkCheckerApiReport exists for #{batch_report_id}"
      Rails.logger.info "It belongs to #{existing_report.link_reportable} not #{reportable}"
    end

    LinkCheckerApiReport.create_from_batch_report(batch_report, reportable)
  end

  def self.webhook_secret_token
    Rails.application.secrets.link_checker_api_secret_token
  end
  private_class_method :webhook_secret_token
end
