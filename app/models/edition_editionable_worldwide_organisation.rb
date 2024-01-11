class EditionEditionableWorldwideOrganisation < ApplicationRecord
  belongs_to :edition
  belongs_to :editionable_worldwide_organisation, inverse_of: :edition_editionable_worldwide_organisations, foreign_key: :worldwide_organisation_id

  validates :edition, :editionable_worldwide_organisation, presence: true
end
