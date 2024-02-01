class WorldwideOrganisationPage < ApplicationRecord
  belongs_to :editionable_worldwide_organisation

  def corporate_information_page_type
    CorporateInformationPageType.find_by_id(corporate_information_page_type_id)
  end
end
