# == Schema Information
#
# Table name: worldwide_organisation_world_locations
#
#  id                        :integer          not null, primary key
#  worldwide_organisation_id :integer
#  world_location_id         :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class WorldwideOrganisationWorldLocation < ActiveRecord::Base
  belongs_to :worldwide_organisation
  belongs_to :world_location
end
