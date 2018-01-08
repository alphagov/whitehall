class LinkCheckerApiService
  def self.has_links?(reportable)
    extract_links(reportable).count > 0
  end

  def self.extract_links(reportable)
    Govspeak::LinkExtractor.new(reportable.body).call
  end

  def self.check_links(reportable, webhook_uri)
    uris = extract_links(reportable)
    raise "Reportable has no links to check" unless uris.count > 0

    batch_report = Whitehall.link_checker_api_client.create_batch(
      uris,
      webhook_uri: webhook_uri,
      webhook_secret_token: webhook_secret_token
    )
    LinkCheckerApiReport.create_from_batch_report(batch_report, reportable)
  end

  def self.webhook_secret_token
    Rails.application.secrets.link_checker_api_secret_token
  end
  private_class_method :webhook_secret_token
end
