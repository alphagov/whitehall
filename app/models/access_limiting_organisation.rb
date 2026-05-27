class AccessLimitingOrganisation < ApplicationRecord
  belongs_to :edition
  belongs_to :organisation, inverse_of: :access_limiting_organisations

  validates :edition, :organisation, presence: true
end
