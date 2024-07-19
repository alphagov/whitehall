class WorldwideOrganisationWorldLocation < ApplicationRecord
  belongs_to :worldwide_organisation
  belongs_to :world_location

  default_scope -> { order(:id) }
end
