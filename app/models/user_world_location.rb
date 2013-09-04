# == Schema Information
#
# Table name: user_world_locations
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  world_location_id :integer
#

class UserWorldLocation < ActiveRecord::Base
  belongs_to :user
  belongs_to :world_location
end
