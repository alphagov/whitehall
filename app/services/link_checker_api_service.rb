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

    batch_report = Whitehall.link_checker_api_client.create_batch(
      uris,
      webhook_uri: webhook_uri,
    )
    LinkCheckerApiReport.create_from_batch_report(batch_report, reportable)
  end
end
