class WorldwideOrganisationPage < ApplicationRecord
  belongs_to :edition

  validates :body, presence: true
  validates :edition, presence: true
  validates :corporate_information_page_type_id,
            presence: true,
            exclusion: { in: [CorporateInformationPageType::AboutUs.id], message: "Type cannot be `About us`" }
  validate :unique_worldwide_organisation_and_page_type, on: :create, if: :edition

  delegate :display_type_key, to: :corporate_information_page_type

  include Attachable

  def title(_locale = :en)
    corporate_information_page_type.title(edition)
  end

  def corporate_information_page_type
    CorporateInformationPageType.find_by_id(corporate_information_page_type_id)
  end

  def corporate_information_page_type=(type)
    self.corporate_information_page_type_id = type && type.id
  end

  def publicly_visible?
    true
  end

  def access_limited?
    false
  end

private

  def unique_worldwide_organisation_and_page_type
    current_page_types = edition.pages.map(&:corporate_information_page_type_id).flatten
    duplicate_page = current_page_types.include?(corporate_information_page_type_id)

    if duplicate_page
      errors.add(:base, "Another '#{display_type_key.humanize}' page already exists for this worldwide organisation")
    end
  end
end
