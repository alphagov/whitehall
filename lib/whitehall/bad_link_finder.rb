require 'bad_link_finder'

module Whitehall
  class BadLinkFinder
    def initialize(mirror_directory)
      @mirror_directory = mirror_directory
    end

    def generate_report(report_path)
      csv = CSV.open(report_path, 'w', encoding: 'UTF-8')
      csv << ["page", "admin link", "department", "format", "bad link count", "bad links"]

      ::BadLinkFinder::Site.new(@mirror_directory, nil).each do |page|
        page_checker = ::BadLinkFinder::PageChecker.new(public_host, page, result_cache)

        if edition = edition_from_identifier(page.id)
          puts "Checking edition #{page.id} at #{page_checker.page_url}"

          bad_links = []

          page_checker.each_bad_link do |bad_link|
            bad_links << bad_link.link
          end

          if bad_links.any?
            data = {
              public_url:     page_checker.page_url,
              admin_url:      Whitehall.url_maker.admin_edition_url(edition, host: 'whitehall-admin.production.alphagov.co.uk'),
              organisation:   (edition.lead_organisations || edition.worldwide_organisations).first.name,
              content_type:   edition.type,
              bad_link_count: bad_links.size,
              bad_links:      bad_links.join("\n")
            }

            csv << data.values
          end
        end
      end

      csv.close
    end

    private

    def result_cache
      @result_cache ||= ::BadLinkFinder::ResultCache.new
    end

    def public_host
      "https://www.gov.uk"
    end

    def edition_from_identifier(identifier)
      if /(.*)_(\d+)/ =~ identifier
        klass = edition_class_from_string($1)
        id = $2

        klass.find_by_id(id) if klass
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
