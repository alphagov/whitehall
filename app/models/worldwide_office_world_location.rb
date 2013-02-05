class WorldwideOfficeWorldLocation < ActiveRecord::Base
  belongs_to :worldwide_office
  belongs_to :world_location
end
