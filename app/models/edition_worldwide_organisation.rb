class EditionWorldwideOrganisation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :worldwide_organisation

  # TODO: Another case of the broken join model association validation
  # validates :edition, :worldwide_organisation, presence: true
end
