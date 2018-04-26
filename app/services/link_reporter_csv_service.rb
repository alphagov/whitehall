class LinkReporterCsvService
  def initialize(reports_dir:, organisation: nil)
    @organisation = organisation
    @reports_dir = reports_dir
    @csv_reports = {}
  end

  def generate
    public_editions.find_each do |edition|
      next unless broken_links(edition).any?
      csv_for_organisation(edition_organisation(edition)) << row_for_edition(edition)
    end

    close_reports
  end

private

  attr_reader :organisation, :reports_dir, :csv_reports

  def public_editions
    if organisation.nil?
      Edition.publicly_visible.with_translations
    else
      Edition.publicly_visible.with_translations.in_organisation(organisation)
    end
  end

  def csv_for_organisation(edition_organisation)
    slug = edition_organisation.try(:slug) || 'no-organisation'
    csv_reports[slug] ||= CsvReport.new(csv_report_path(slug))
  end

  def csv_report_path(file_prefix)
    Pathname.new(reports_dir).join("#{file_prefix}_links_report.csv")
  end

  def close_reports
    csv_reports.each_value(&:close)
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

  def edition_organisation(edition)
    if edition.respond_to?(:worldwide_organisations)
      edition.worldwide_organisations.first
    elsif edition.respond_to?(:lead_organisations)
      edition.lead_organisations.first || edition.organisations.first
    else
      edition.organisations.first
    end
  end

  # These hosts are hardcoded because we run this on integration but want the
  # generated URLs to be production ones.
  def public_host
    "www.gov.uk"
  end

  def admin_host
    "whitehall-admin.publishing.service.gov.uk"
  end

  class CsvReport
    delegate :<<, :close, to: :csv

    def initialize(file_path)
      @csv = CSV.open(file_path, 'w', encoding: 'UTF-8')
      @csv << headings
    end

  private

    attr_accessor :csv

    def headings
      ["page", "admin link", "public timestamp", "format", "broken link count", "broken links"]
    end
  end
end
