class DeleteWorldwideOrganisationAboutPages < ActiveRecord::Migration[7.0]
  class Edition < ApplicationRecord
  end

  class CorporateInformationPage < Edition
    ABOUT_US_TYPE_ID = 20
  end

  class WorldwideOrganisation < ApplicationRecord
    has_many :edition_worldwide_organisations
    has_many :corporate_information_pages, through: :edition_worldwide_organisations, source: :edition, class_name: "::CorporateInformationPage"

    def about_us_page_editions
      corporate_information_pages.where(corporate_information_page_type_id: CorporateInformationPage::ABOUT_US_TYPE_ID)
    end
  end

  def up
    WorldwideOrganisation.all.each do |worldwide_organisation|
      worldwide_organisation.about_us_page_editions.destroy_all
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
