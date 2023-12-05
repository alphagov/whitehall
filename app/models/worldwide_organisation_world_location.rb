class WorldwideOrganisationWorldLocation < ApplicationRecord
  belongs_to :legacy_worldwide_organisation, foreign_key: :worldwide_organisation_id
  belongs_to :world_location
end
