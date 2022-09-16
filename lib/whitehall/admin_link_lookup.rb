module Whitehall
  class AdminLinkLookup
    include Govspeak::EmbeddedContentPatterns

    def self.find_edition(admin_url)
      case admin_url
      when ADMIN_ORGANISATION_CIP_PATH
        organisation = Organisation.find_by(slug: Regexp.last_match(1))
        corporate_info_page(organisation:, corporate_info_slug: Regexp.last_match(2))
      when ADMIN_WORLDWIDE_ORGANISATION_CIP_PATH
        organisation = WorldwideOrganisation.find_by(slug: Regexp.last_match(1))
        corporate_info_page(organisation:, corporate_info_slug: Regexp.last_match(2))
      when ADMIN_EDITION_PATH
        Edition.unscoped.find_by(id: Regexp.last_match(1))
      end
    end

    def self.corporate_info_page(organisation:, corporate_info_slug:)
      return nil unless organisation

      organisation.corporate_information_pages.find(corporate_info_slug)
    end

    private_class_method :corporate_info_page
  end
end
