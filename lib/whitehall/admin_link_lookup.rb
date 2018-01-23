module Whitehall
  class AdminLinkLookup
    include Govspeak::EmbeddedContentPatterns

    def self.find_edition(admin_url)
      case admin_url
      when ADMIN_ORGANISATION_CIP_PATH
        organisation = Organisation.find_by(slug: $1)
        corporate_info_page(organisation: organisation, corporate_info_slug: $2)
      when ADMIN_WORLDWIDE_ORGANISATION_CIP_PATH
        organisation = WorldwideOrganisation.find_by(slug: $1)
        corporate_info_page(organisation: organisation, corporate_info_slug: $2)
      when ADMIN_EDITION_PATH
        Edition.unscoped.find_by(id: $1)
      end
    end

    def self.corporate_info_page(organisation:, corporate_info_slug:)
      organisation.corporate_information_pages.find(corporate_info_slug)
    end

    private_class_method :corporate_info_page
  end
end
