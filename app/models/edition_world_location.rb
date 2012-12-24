class EditionWorldLocation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :world_location
end