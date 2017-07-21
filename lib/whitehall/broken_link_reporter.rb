# Generates CSV reports of all public documents containing broken links.
module Whitehall
  class BrokenLinkReporter
    attr_reader :csv_reports, :logger, :organisation

    def initialize(csv_reports_dir, logger = Rails.logger, organisation = nil)
      @csv_reports_dir = csv_reports_dir
      @csv_reports = {}
      @logger = logger
      @organisation = organisation
    end

    def generate_reports
      public_editions.find_each do |edition|
        logger.info "Checking #{edition.type} (#{edition.id}) for bad links"

        checker = EditionChecker.new(edition)
        checker.check_links

        if checker.broken_links.any?
          csv_for_organisation(checker.organisation) << csv_row_for(checker)
        end
      end

      close_reports
    end

  private

    def public_editions
      if organisation.nil?
        Edition.publicly_visible.with_translations
      else
        Edition.publicly_visible.with_translations.in_organisation(organisation)
      end
    end

    def csv_row_for(checker)
      [checker.public_url,
        checker.admin_url,
        checker.timestamp,
        checker.edition_type,
        checker.broken_links.size,
        checker.broken_links.join("\r\n")]
    end

    def csv_for_organisation(organisation)
      slug = organisation.try(:slug) || 'no-organisation'
      csv_reports[slug] ||= CsvReport.new(csv_report_path(slug))
    end

    def csv_report_path(file_prefix)
      Pathname.new(@csv_reports_dir).join("#{file_prefix}_broken_links.csv")
    end

    def close_reports
      csv_reports.each_value(&:close)
    end

    class EditionChecker
      attr_reader :edition, :broken_links

      def initialize(edition)
        @edition = edition
      end

      def public_url
        Whitehall.url_maker.public_document_url(edition, host: public_host, protocol: 'https')
      end

      def admin_url
        Whitehall.url_maker.admin_edition_url(edition, host: admin_host, protocol: 'https')
      end

      def edition_type
        edition.type
      end

      def organisation
        if edition.respond_to?(:worldwide_organisations)
          edition.worldwide_organisations.first
        elsif edition.respond_to?(:lead_organisations)
          edition.lead_organisations.first || edition.organisations.first
        else
          edition.organisations.first
        end
      end

      def timestamp
        edition.public_timestamp.to_s
      end

      def links
        @links ||= Govspeak::LinkExtractor.new(edition.body).links
      end

      def check_links
        if links.any?
          run_links_report
          @broken_links = edition.links_reports.last.broken_links
        else
          @broken_links = []
        end
      end

    private

      # These hosts are hardcoded because we run this on integration but want the
      # generated URLs to be production ones.
      def public_host
        "www.gov.uk"
      end

      def admin_host
        'whitehall-admin.publishing.service.gov.uk'
      end

      def run_links_report
        links_report = LinksReport.create!(link_reportable: edition, links: links)
        LinksReportWorker.new.perform(links_report.id)
      end
    end

    class CsvReport
      delegate :<<, :close, to: :csv

      def initialize(file_path)
        @csv = CSV.open(file_path, 'w', encoding: 'UTF-8')
        @csv << headings
      end

    private
      def csv
        @csv
      end

      def headings
        ["page", "admin link", "public timestamp", "format", "broken link count", "broken links"]
      end
    end
  end
end
