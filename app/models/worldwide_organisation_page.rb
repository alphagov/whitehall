class WorldwideOrganisationPage < ApplicationRecord
  belongs_to :edition

  validates :body, presence: true
  validates :edition, presence: true
  validates :corporate_information_page_type_id, presence: true

  def title(_locale = :en)
    corporate_information_page_type.title(edition)
  end

  def corporate_information_page_type
    CorporateInformationPageType.find_by_id(corporate_information_page_type_id)
  end

  def corporate_information_page_type=(type)
    self.corporate_information_page_type_id = type && type.id
  end
end
