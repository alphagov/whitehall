class WorldLocationTopTask < ActiveRecord::Base
  belongs_to :top_task
  belongs_to :world_location
end
