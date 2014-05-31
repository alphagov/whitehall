class UserWorldLocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :world_location
end
