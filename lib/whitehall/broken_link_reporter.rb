# Generates CSV reports of all public documents containing broken links.
module Whitehall
  class BrokenLinkReporter
    attr_reader :csv_reports, :logger

    def initialize(csv_reports_dir, logger = Rails.logger)
      @csv_reports_dir = csv_reports_dir
      @csv_reports = {}
      @logger = logger
    end

    def generate_reports
      public_editions.find_each do |edition|
        logger.info "Checking #{edition.type} (#{edition.id}) for bad links"

        checker = EditionChecker.new(edition)
        checker.check_links

        if checker.broken_links.any?
          csv_for_organisation(checker.lead_organisation) << csv_row_for(checker)
        end
      end

      close_reports
    end

  private

    def public_editions
      Edition.publicly_visible.with_translations
    end

    def csv_row_for(checker)
      [checker.public_url,
        checker.admin_url,
        checker.edition_type,
        checker.broken_links.size,
        checker.broken_links.join("\r\n")]
    end

    def csv_for_organisation(organisation)
        csv_reports[organisation.slug] ||= CsvReport.new(csv_report_path(organisation))
    end

    def csv_report_path(organisation)
      Pathname.new(@csv_reports_dir).join("#{organisation.slug}_broken_links.csv")
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

      def lead_organisation
        if edition.lead_organisations.any?
          edition.lead_organisations.first
        else
          edition.worldwide_organisations.first
        end
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

      # These hosts are hardcoded because we run this on preview but want the
      # generated URLs to be production ones.
      def public_host
        "www.gov.uk"
      end

      def admin_host
        'whitehall-admin.production.alphagov.co.uk'
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
        ["page", "admin link", "format", "broken link count", "broken links"]
      end
    end
  end
end
