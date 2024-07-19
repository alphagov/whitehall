class EditionWorldwideOrganisation < ApplicationRecord
  belongs_to :edition
  belongs_to :worldwide_organisation, inverse_of: :edition_worldwide_organisations

  validates :edition, :worldwide_organisation, presence: true
end
