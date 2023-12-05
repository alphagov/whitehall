class EditionWorldwideOrganisation < ApplicationRecord
  belongs_to :edition
  belongs_to :legacy_worldwide_organisation, class_name: "LegacyWorldwideOrganisation", inverse_of: :edition_worldwide_organisations, foreign_key: :worldwide_organisation_id

  validates :edition, :legacy_worldwide_organisation, presence: true
end
