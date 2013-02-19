class WorldwideOrganisationWorldLocation < ActiveRecord::Base
  belongs_to :worldwide_organisation
  belongs_to :world_location
end
