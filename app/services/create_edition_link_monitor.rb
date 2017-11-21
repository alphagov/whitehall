class CreateEditionLinkMonitor
  def initialize(edition)
    @edition = edition
    @uris = extract_links
  end

  def perform!
    if can_perform?
      upsert_resource_monitor

      true
    end
  end

  def can_perform?
    !failure_reason
  end

  def failure_reason
    "This edition has no links" unless has_links?
  end

private

  attr_reader :edition, :uris

  def upsert_resource_monitor
    Whitehall.link_checker_api_client.upsert_resource_monitor(
      uris,
      :whitehall,
      edition_reference
    )
  end

  def edition_reference
    "edition:#{edition.id}"
  end

  def has_links?
    extract_links.count > 0
  end

  def extract_links
    @extract_links ||= Govspeak::LinkExtractor.new(edition.body).links
  end
end
