class LinkReporterCsvService
  def initialize(reports_dir:, organisation:)
    @organisation = organisation
    @reports_dir = reports_dir
  end

  def generate
    CSV.open(file_path, "w", encoding: "UTF-8") do |csv|
      csv << headings
      public_editions.each do |edition|
        csv << row_for_edition(edition) if broken_links(edition).any?
      end
    end
  end

private

  attr_reader :organisation, :reports_dir

  def public_editions
    Edition.publicly_visible.with_translations.in_organisation(organisation)
  end

  def file_path
    reports_dir.join("#{@organisation.slug}_links_report.csv")
  end

  def headings
    ["page", "admin link", "public timestamp", "format", "broken link count", "broken links"]
  end

  def row_for_edition(edition)
    [
      public_url(edition),
      admin_url(edition),
      timestamp(edition),
      edition.type,
      broken_links(edition).size,
      broken_links(edition).join("\r\n")
    ]
  end

  def public_url(edition)
    Whitehall.url_maker.public_document_url(edition, host: public_host, protocol: "https")
  end

  def admin_url(edition)
    Whitehall.url_maker.admin_edition_url(edition, host: admin_host, protocol: "https")
  end

  def timestamp(edition)
    edition.public_timestamp.to_s
  end

  def broken_links(edition)
    return [] unless edition.link_check_reports.present?
    edition.link_check_reports.last.broken_links.map(&:uri)
  end

  # These hosts are hardcoded because we run this on integration but want the
  # generated URLs to be production ones.
  def public_host
    "www.gov.uk"
  end

  def admin_host
    "whitehall-admin.publishing.service.gov.uk"
  end
end
