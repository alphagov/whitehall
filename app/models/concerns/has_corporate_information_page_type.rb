module HasCorporateInformationPageType
  extend ActiveSupport::Concern

  delegate :slug, :display_type_key, to: :corporate_information_page_type

  included do
    def corporate_information_page_type
      CorporateInformationPageType.find_by_id(corporate_information_page_type_id)
    end

    def corporate_information_page_type=(type)
      self.corporate_information_page_type_id = type && type.id
    end

    def self.by_menu_heading(menu_heading)
      type_ids = CorporateInformationPageType.by_menu_heading(menu_heading).map(&:id)
      where(corporate_information_page_type_id: type_ids)
    end

    def self.for_slug(slug)
      if (type = CorporateInformationPageType.find(slug))
        find_by(corporate_information_page_type_id: type.id)
      end
    end

    def self.for_slug!(slug)
      if (type = CorporateInformationPageType.find(slug))
        find_by!(corporate_information_page_type_id: type.id)
      end
    end
  end
end
