class WorldLocationMainstreamLink < ActiveRecord::Base
  belongs_to :mainstream_link
  belongs_to :world_location
end
