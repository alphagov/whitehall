class EditionWorldwideOrganisation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :worldwide_organisation

  validates :edition, :worldwide_organisation, presence: true
end
