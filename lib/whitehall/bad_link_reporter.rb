require 'bad_link_finder'

module Whitehall
  # Used to report on the bad links (404s, etc) that are currently on GOV.UK.
  #
  # This class takes a directory containing a mirror of the site, crawls each
  # page, checking any links to see if they are reachable, and generates a
  # series of CSV files listing the pages that were found to have bad links.
  # Pages containing bad links are grouped by their lead organisation, with
  # each organisation getting its own CSV file, named using the organisation's
  # slug.
  class BadLinkReporter
    attr_reader :csv_reports, :logger

    def initialize(mirror_dir, csv_reports_dir, logger = Rails.logger)
      @mirror_dir = mirror_dir
      @csv_reports_dir = csv_reports_dir
      @csv_reports = {}
      @logger = logger
    end

    def generate_reports
      ::BadLinkFinder::Site.new(@mirror_dir, nil).each do |page|
        page_checker = PageChecker.new(page, ::BadLinkFinder::ResultCache.new, logger)

        if page_checker.is_edition?
          logger.info "Checking #{page_checker.edition.type} (#{page_checker.edition.id}) for bad links"
          if page_checker.bad_links.any?
            csv_report_for_organisation(page_checker.lead_organisation) << csv_row_for(page_checker)
          end
        end
      end

      close_reports
    end

  private

    def csv_row_for(page_checker)
      [page_checker.page_url,
        page_checker.admin_url,
        page_checker.edition.type,
        page_checker.raw_bad_links.size,
        page_checker.raw_bad_links.join("\r\n")]
    end

    def csv_report_for_organisation(organisation)
        csv_reports[organisation.slug] ||= CsvReport.new(csv_report_path(organisation))
    end

    def csv_report_path(organisation)
      Pathname.new(@csv_reports_dir).join("#{organisation.slug}_bad_links.csv")
    end

    def close_reports
      csv_reports.each_value(&:close)
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
        ["page", "admin link", "format", "bad link count", "bad links"]
      end
    end

    class PageChecker < ::BadLinkFinder::PageChecker

      def initialize(page, result_cache, logger = Rails.logger)
        super(public_host, page, result_cache, logger)
      end

      def edition
        @edition ||= find_edition
      end

      def is_edition?
        edition.present?
      end

      def admin_url
        if edition
          Whitehall.url_maker.admin_edition_url(edition, host: admin_host, protocol: 'https')
        end
      end

      def lead_organisation
        edition.lead_organisations.any? ? edition.lead_organisations.first : edition.worldwide_organisations.first
      end

      def raw_bad_links
        @raw_bad_links ||= bad_links.map(&:link)
      end

    private

      # These hosts are hardcoded because we run this on preview but want the
      # generated URLs to be production ones.
      def public_host
        "https://www.gov.uk"
      end

      def admin_host
        'whitehall-admin.production.alphagov.co.uk'
      end

      def find_edition
        if /(.*)_(\d+)/ =~ @page.id
          klass = edition_class_from_string($1)
          id = $2

          klass.with_translations.includes(:organisations).find_by_id(id) if klass
        end
      end

      def edition_class_from_string(klass_identifier)
        klass = klass_identifier.classify.constantize
        klass if Whitehall.edition_classes.include?(klass)
      rescue NameError
        nil
      end
    end
  end
end
