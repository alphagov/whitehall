class LinkCheckerApiService
  def self.has_links?(edition, convert_admin_links: true)
    links = extract_links(edition)
    links = convert_admin_links(links) if convert_admin_links
    links.any?
  end

  def self.has_admin_draft_links?(edition)
    links = extract_links(edition)
    converted = convert_admin_links(links)
    links.count > converted.count
  end

  def self.extract_links(edition)
    Govspeak::Document.new(edition.body).extracted_links(website_root:)
  end

  def self.check_links(edition, webhook_uri, checked_within: nil)
    uris = convert_admin_links(extract_links(edition))
    if uris.empty?
      # We'll create a noop report for the simplicity in there being a report
      LinkCheckerApiReport.create_noop_report(edition)
    else
      batch_report = Whitehall.link_checker_api_client.create_batch(
        uris,
        checked_within:,
        webhook_uri:,
        webhook_secret_token:,
      )

      LinkCheckerApiReport.create_in_progress_report(batch_report, edition)
    end
  end

  def self.convert_admin_links(links)
    converted = links.map do |link|
      edition = Whitehall::AdminLinkLookup.find_edition(link)
      if edition
        edition.public_url if edition.published?
      else
        link
      end
    end
    converted.compact
  end

  def self.webhook_secret_token
    Rails.application.credentials.link_checker_api_secret_token
  end

  def self.website_root
    @website_root ||= Plek.website_root
  end

  private_class_method :webhook_secret_token, :website_root, :convert_admin_links
end
