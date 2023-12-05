class Sponsorship < ApplicationRecord
  belongs_to :organisation
  belongs_to :legacy_worldwide_organisation, foreign_key: :worldwide_organisation_id
end
