class UserWorldLocation < ApplicationRecord
  belongs_to :user
  belongs_to :world_location
end
